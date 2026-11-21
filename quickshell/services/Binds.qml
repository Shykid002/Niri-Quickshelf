pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The Keybindings window's data. bin/rice-keys reads niri's config (and its includes) every time
// the window opens, so the list is always what is really bound.
Singleton {
    id: root
    property bool open: false
    property var groups: []              // [{ name, items: [{ key, desc, src }] }]
    property var files: []
    property int count: 0
    property string error: ""

    function toggle() { open = !open; if (open) refresh() }
    function close()  { open = false }
    function refresh() { if (!proc.running) proc.running = true }

    Process {
        id: proc
        command: ["sh", "-c", "\"$HOME/.local/bin/rice-keys\""]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.groups = d.groups; root.files = d.files; root.count = d.count; root.error = "";
                } catch (e) { root.error = "could not read the niri config (is rice-keys installed? run ./install.sh)" }
            }
        }
    }
}
