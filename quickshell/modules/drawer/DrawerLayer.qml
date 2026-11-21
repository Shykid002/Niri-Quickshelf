import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services

// Slide-in drawer on the right, under the bar, with a flat scrim over the rest of the screen.
// Keybinds: see niri/keybinds.kdl
// The windows exist only while the drawer is open or sliding out (a timer, not an animation
// flag), and the slide is switched off during startup so nothing can appear open at launch.
Scope {
    IpcHandler {
        target: "drawer"
        function index(): void { Drawer.toggleDefault("index") }
        function day(): void   { Drawer.toggleDefault("day") }
        function close(): void { Drawer.close() }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: sc
            required property var modelData
            readonly property bool shown: Drawer.open && Drawer.screenName === modelData.name
            property bool mapped: false
            property bool ready: false
            onShownChanged: { if (shown) { hide.stop(); mapped = true } else if (mapped) hide.restart() }
            Timer { id: hide; interval: 260 * Prefs.speed; onTriggered: sc.mapped = false }
            Timer { interval: 1200; running: true; onTriggered: sc.ready = true }

            PanelWindow {   // scrim: flat paper wash, click to close
                screen: sc.modelData
                visible: sc.mapped
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                anchors { top: true; bottom: true; left: true; right: true }
                margins.top: 27
                WlrLayershell.namespace: "rice-scrim"
                Rectangle { anchors.fill: parent; color: Theme.paper; opacity: sc.shown ? 0.6 : 0 }
                MouseArea { anchors.fill: parent; onClicked: Drawer.close() }
            }

            PanelWindow {
                screen: sc.modelData
                visible: sc.mapped
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                anchors { top: true; bottom: true; right: true }
                margins.top: 27
                implicitWidth: 348
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "rice-drawer"
                WlrLayershell.keyboardFocus: sc.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

                DrawerPanel {
                    width: 348; height: parent.height
                    x: sc.shown ? 0 : 348
                    Behavior on x { enabled: sc.ready; NumberAnimation { duration: 180 * Prefs.speed; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
