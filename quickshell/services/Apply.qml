pragma Singleton
import QtQuick
import Quickshell
import qs
import qs.services

Singleton {
    id: root
    function start() {}
    property bool ready: false
    readonly property string args: new Array(
        Prefs.gaps || "-",
        Prefs.border || "-",
        Prefs.tap ? 1 : 0,
        Prefs.natural ? 1 : 0,
        Prefs.fontSize || "-",
        Prefs.focusFollowsMouse ? 1 : 0,
        Prefs.dwt ? 1 : 0,
        Prefs.cursorStyle || "box",
        Prefs.cursorSize || 24,
        Prefs.kbLayout || "us"
    ).join(" ")

    onArgsChanged: if (ready) debounce.restart()

    Timer { interval: 1500; running: true; onTriggered: { root.ready = true; Theme.syncApps(Theme.dark) } }
    Connections {
        target: Prefs
        function onCoverChanged() { Theme.syncApps(Theme.dark) }
        function onCursorStyleChanged() { Theme.syncNow(Theme.dark) }
        function onCursorSizeChanged() { Theme.syncNow(Theme.dark) }
        function onKbLayoutChanged() {
            if (typeof OskState !== "undefined") OskState.layout = (Prefs.kbLayout === "ara" ? "ARA" : "US");
        }
    }
    Timer {
        id: debounce; interval: 250
        onTriggered: Quickshell.execDetached(new Array("sh", "-c", '"$HOME/.local/bin/rice-apply" ' + root.args))
    }
}
