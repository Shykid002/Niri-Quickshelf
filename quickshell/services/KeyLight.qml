pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Keyboard backlight (the MacBook's smc::kbd_backlight, or any "kbd_backlight" LED).
// Same method as the screen light: read with brightnessctl, write through systemd-logind
// (no permissions needed), brightnessctl as the fallback. Hidden in the drawer if there is none.
Singleton {
    id: root
    property real percent: 0
    property bool available: false
    property string error: ""
    property string device: ""
    property real maxRaw: 0

    function refresh() { if (!read.running && !throttle.running) read.running = true }
    function set(p) {
        percent = Math.max(0, Math.min(100, p));           // 0 = backlight off, which is fine here
        if (!throttle.running) throttle.start();
    }
    function viaCtl() {
        if (ctl.running || device === "") return;
        ctl.command = ["brightnessctl", "-d", device, "set", Math.round(percent) + "%"];
        ctl.running = true;
    }
    function send() {
        if (device === "" || maxRaw <= 0) { viaCtl(); return; }
        if (logind.running) { throttle.start(); return; }
        const raw = Math.round(percent / 100 * maxRaw);
        logind.command = ["busctl", "call", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto",
                          "org.freedesktop.login1.Session", "SetBrightness", "ssu", "leds", device, String(raw)];
        logind.running = true;
    }

    Process {
        id: read
        command: ["brightnessctl", "-m", "--class=leds"]      // name,class,value,percent,max  (one line per LED)
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = false;
                for (const line of text.split("\n")) {
                    const f = line.split(",");
                    if (f.length >= 5 && f[0].indexOf("kbd_backlight") >= 0) {
                        root.device = f[0];
                        root.maxRaw = parseFloat(f[4]) || 0;
                        root.percent = parseFloat(f[3]) || 0;
                        root.available = true;
                        return;
                    }
                }
            }
        }
    }
    Process {
        id: logind
        onExited: (code, status) => { if (code === 0) root.error = ""; else root.viaCtl() }
    }
    Process {
        id: ctl
        stderr: StdioCollector {
            onStreamFinished: root.error = text.trim() === "" ? "" : text.trim().split("\n")[0]
        }
    }
    Timer { id: throttle; interval: 70; onTriggered: root.send() }
    Timer { interval: 6000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
}
