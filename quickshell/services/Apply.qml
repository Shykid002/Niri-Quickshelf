pragma Singleton
import QtQuick
import Quickshell
import qs
import qs.services

// Pushes Windows / Input / Terminal settings out to niri and Ghostty (bin/rice-apply) when they change.
Singleton {
    id: root
    function start() {}                    // referencing this singleton is what creates it
    property bool ready: false
    readonly property string args: [Prefs.gaps || "-", Prefs.border || "-", Prefs.tap ? 1 : 0,
                                    Prefs.natural ? 1 : 0, Prefs.fontSize || "-"].join(" ")
    onArgsChanged: if (ready) debounce.restart()

    Timer { interval: 1500; running: true; onTriggered: { root.ready = true; Theme.syncApps(Theme.dark) } }   // ignore the initial load, then sync apps once
    Connections { target: Prefs; function onCoverChanged() { coverDebounce.restart() } }
    Timer { id: coverDebounce; interval: 300; onTriggered: Theme.syncApps(Theme.dark) }
    Timer {
        id: debounce; interval: 400
        onTriggered: Quickshell.execDetached(["sh", "-c", '"$HOME/.local/bin/rice-apply" ' + root.args])
    }
}
