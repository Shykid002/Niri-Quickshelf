pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// "1 working" next to Index, and the Sessions list in the launcher.
// There is no standard source for this, so it counts running AI-coding sessions: processes
// named `pattern` (default "claude", i.e. Claude Code). Each shows its folder and how long it has run.
// Change `pattern` if yours is named differently (check with:  pgrep -a claude).
Singleton {
    id: root
    property string pattern: "claude"
    property var items: []                       // { pid, title, path, minutes }
    readonly property int count: items.length

    function refresh() { if (!proc.running) proc.running = true }

    Process {
        id: proc
        command: ["sh", "-c", "for p in $(pgrep -x " + root.pattern + "); do echo \"$p|$(ps -o etimes= -p $p | tr -d ' ')|$(readlink /proc/$p/cwd)\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    const f = line.split("|");
                    if (f.length < 3 || !f[0]) continue;
                    const path = f[2] || "";
                    out.push({ pid: f[0], path: path, minutes: Math.floor((parseInt(f[1]) || 0) / 60),
                               title: path.split("/").filter(x => x).pop() || root.pattern });
                }
                root.items = out;
            }
        }
    }
    Timer { interval: 8000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
    Connections { target: Drawer; function onOpenChanged() { if (Drawer.open) root.refresh() } }
}
