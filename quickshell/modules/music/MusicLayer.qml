import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.music      // needed because this file is loaded on its own (see shell.qml); lets it find MusicCard

// The music window drops from the top, under the bar:   Mod+P   (qs -c rice ipc call music toggle)
// Same safety as the drawer: the windows exist only while it is open or sliding away, and the slide
// is switched off for the first second after start-up.
Scope {
    IpcHandler {
        target: "music"
        function toggle(): void { Music.toggleDefault() }
        function open(): void   { if (!Music.open) Music.toggleDefault() }
        function close(): void  { Music.close() }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: sc
            required property var modelData
            readonly property bool shown: Music.open && Music.screenName === modelData.name
            property bool mapped: false
            property bool ready: false
            onShownChanged: { if (shown) { hide.stop(); mapped = true } else if (mapped) hide.restart() }
            Timer { id: hide; interval: 320 * Prefs.speed; onTriggered: sc.mapped = false }
            Timer { interval: 1200; running: true; onTriggered: sc.ready = true }

            PanelWindow {   // click anywhere outside to close
                screen: sc.modelData
                visible: sc.mapped
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                anchors { top: true; bottom: true; left: true; right: true }
                margins.top: 27
                WlrLayershell.namespace: "rice-music-catcher"
                MouseArea { anchors.fill: parent; onClicked: Music.close() }
            }

            PanelWindow {
                screen: sc.modelData
                visible: sc.mapped
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                anchors { top: true }                      // one edge: centred along the top
                margins.top: 27
                implicitWidth: 760
                implicitHeight: card.height
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "rice-music"
                WlrLayershell.keyboardFocus: sc.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

                MusicCard {
                    id: card
                    width: 760
                    y: sc.shown ? 0 : -height
                    Behavior on y { enabled: sc.ready; NumberAnimation { duration: 240 * Prefs.speed; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
