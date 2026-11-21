pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Screen backlight.
//  read : brightnessctl -m   (reading never needs permissions)
//  write: systemd-logind SetBrightness over D-Bus. It works for your own logged-in session with
//         no group or udev setup, which is how desktop environments do it.
//         If that fails, brightnessctl set is tried and its message is shown in the Day tab.
Singleton {
    id: root
    property real percent: 50
    property bool available: false
    property string error: ""
    property string device: ""
    property string kind: "backlight"
    signal userChanged()
    property real maxRaw: 0

    function refresh() { if (!read.running && !throttle.running) read.running = true }
    function set(p) {
        percent = Math.max(1, Math.min(100, p));          // never 0: that is a black screen
        userChanged();
        if (!throttle.running) throttle.start();
    }
    function viaCtl() {
        if (ctl.running) return;
        ctl.command = ["brightnessctl", "set", Math.round(percent) + "%"];
        ctl.running = true;
    }
    function send() {
        if (device === "" || maxRaw <= 0) { viaCtl(); return; }
        if (logind.running) { throttle.start(); return; }
        const raw = Math.max(1, Math.round(percent / 100 * maxRaw));
        logind.command = ["busctl", "call", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto",
                          "org.freedesktop.login1.Session", "SetBrightness", "ssu", kind, device, String(raw)];
        logind.running = true;
    }

    Process {
        id: read
        command: ["brightnessctl", "-m"]                   // name,class,value,percent,max
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                if (f.length >= 5) {
                    root.available = true;
                    root.device = f[0]; root.kind = f[1];
                    root.maxRaw = parseFloat(f[4]) || 0;
                    root.percent = parseFloat(f[3]) || root.percent;
                } else root.available = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: { if (text.trim() !== "") root.error = text.trim().split("\n")[0] }
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
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
}
