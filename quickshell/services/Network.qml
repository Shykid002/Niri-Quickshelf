pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wi-Fi through NetworkManager (nmcli).
Singleton {
    id: root

    property bool enabled: true
    property bool connected: false
    property string ssid: ""
    property int signal: 0              // 0..100
    property string band: ""            // "2.4 GHz" | "5 GHz" | "6 GHz"
    property var networks: []           // other networks, strongest first: { ssid, signal, secure }

    readonly property string quality: signal >= 70 ? "good" : signal >= 45 ? "fair" : "weak"
    readonly property string detail: connected ? "connected, " + quality + (band ? ", " + band : "") : "not connected"

    function refresh(rescan) {
        if (!radio.running) radio.running = true;
        if (list.running) return;
        list.command = ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY,FREQ", "dev", "wifi", "list"]
                       .concat(rescan ? ["--rescan", "yes"] : []);
        list.running = true;
    }
    function setEnabled(on) {
        enabled = on;
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        settle.restart();
    }
    function connect(name) {
        Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", name]);
        settle.restart();
    }

    // nmcli -t escapes ":" and "\" inside values with a backslash
    function splitTerse(line) {
        const out = []; let cur = "";
        for (let i = 0; i < line.length; i++) {
            const ch = line[i];
            if (ch === "\\" && i + 1 < line.length) { cur += line[i + 1]; i++; }
            else if (ch === ":") { out.push(cur); cur = ""; }
            else cur += ch;
        }
        out.push(cur);
        return out;
    }
    function bandOf(freq) {
        const f = parseInt(freq);
        if (!f) return "";
        return f < 3000 ? "2.4 GHz" : f < 5900 ? "5 GHz" : "6 GHz";
    }

    Process {
        id: list
        stdout: StdioCollector {
            onStreamFinished: {
                const best = {};
                let active = null;
                for (const line of text.split("\n")) {
                    if (!line) continue;
                    const f = root.splitTerse(line);       // IN-USE, SSID, SIGNAL, SECURITY, FREQ
                    if (!f[1]) continue;
                    const n = { ssid: f[1], signal: parseInt(f[2]) || 0,
                                secure: f[3] !== "" && f[3] !== "--", band: root.bandOf(f[4]) };
                    if (f[0] === "*") active = n;
                    if (!best[n.ssid] || best[n.ssid].signal < n.signal) best[n.ssid] = n;
                }
                root.connected = active !== null;
                root.ssid   = active ? active.ssid : "";
                root.signal = active ? active.signal : 0;
                root.band   = active ? active.band : "";
                root.networks = Object.values(best)
                    .filter(n => !active || n.ssid !== active.ssid)
                    .sort((a, b) => b.signal - a.signal);
            }
        }
    }
    Process {
        id: radio
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: root.enabled = text.trim() === "enabled" }
    }
    Timer { interval: 8000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh(false) }
    Timer { id: settle; interval: 1200; onTriggered: root.refresh(false) }
}
