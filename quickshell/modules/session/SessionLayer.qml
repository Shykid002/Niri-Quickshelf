import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Slides in from the right edge under the bar, with the same flat paper wash as the drawer.
// Same safety as the drawer: windows exist only while open or sliding out, slide off at startup.
Variants {
    model: Quickshell.screens

    Scope {
        id: sc
        required property var modelData
        readonly property bool shown: Session.open && Session.screenName === modelData.name
        property bool mapped: false
        property bool ready: false
        onShownChanged: { if (shown) { hide.stop(); mapped = true } else if (mapped) hide.restart() }
        Timer { id: hide; interval: 260 * Prefs.speed; onTriggered: sc.mapped = false }
        Timer { interval: 1200; running: true; onTriggered: sc.ready = true }

        PanelWindow {   // scrim, click to close
            screen: sc.modelData
            visible: sc.mapped
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            margins.top: 27
            WlrLayershell.namespace: "rice-scrim-session"
            Rectangle { anchors.fill: parent; color: Theme.paper; opacity: sc.shown ? 0.6 : 0 }
            MouseArea { anchors.fill: parent; onClicked: Session.close() }
        }

        PanelWindow {
            screen: sc.modelData
            visible: sc.mapped
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; right: true }
            margins.top: 27
            implicitWidth: 105
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "rice-session"
            WlrLayershell.keyboardFocus: sc.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            SessionPanel {
                width: 105; height: parent.height
                x: sc.shown ? 0 : 105
                Behavior on x { enabled: sc.ready; NumberAnimation { duration: 180 * Prefs.speed; easing.type: Easing.OutCubic } }
            }
        }
    }
}
