pragma Singleton
import QtQuick
import Quickshell
import qs.services

// The little bar that appears at the bottom of the screen when sound or light changes
// (keys, slider in a popup, anything). Not shown while the drawer is open: it has its own sliders.
Singleton {
    id: root
    function start() {}
    property bool shown: false
    property string kind: "sound"                         // "sound" | "light"
    property bool ready: false
    readonly property string label: kind === "sound" ? (Audio.muted ? "Sound, muted" : "Sound") : "Light"
    readonly property real value: kind === "sound" ? Audio.volume * 100 : Brightness.percent
    readonly property bool dim: kind === "sound" && Audio.muted
    readonly property string screenName: Niri.focusedOutput || (Quickshell.screens.length ? Quickshell.screens[0].name : "")

    function show(k) { if (Drawer.open || Session.open) return; kind = k; shown = true; hide.restart() }

    Timer { id: hide; interval: 1600; onTriggered: root.shown = false }
    Timer { interval: 2500; running: true; onTriggered: root.ready = true }
    Connections {
        target: Audio
        function onVolumeChanged() { if (root.ready) root.show("sound") }
        function onMutedChanged()  { if (root.ready) root.show("sound") }
    }
    Connections {
        target: Brightness
        function onUserChanged() { if (root.ready) root.show("light") }
    }
}
