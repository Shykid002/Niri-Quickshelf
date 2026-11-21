import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services

// Draws the page-turn above everything while a theme change runs.
// The overlay window only EXISTS during the animation (LazyLoader), so it can never
// block clicks the rest of the time, even on compositors that ignore input masks.
// Try the modes without the Settings app:
//   qs -c rice ipc call theme mode held|leaf|ink|none
//   qs -c rice ipc call theme motion quick|usual|slow
//   qs -c rice ipc call theme toggle
Scope {
    IpcHandler {
        target: "theme"
        function toggle(): void { Theme.toggle() }
        function mode(name: string): void { Prefs.themeChange = name }
        function motion(name: string): void { Prefs.motion = name }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: sc
            required property var modelData

            LazyLoader {
                active: PageTurn.running

                PanelWindow {
                    id: win
                    screen: sc.modelData
                    color: "transparent"
                    mask: Region {}                   // click-through where supported
                    exclusionMode: ExclusionMode.Ignore
                    anchors { top: true; bottom: true; left: true; right: true }
                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.namespace: "rice-transition"

                    readonly property bool sweep: PageTurn.mode === "held" || PageTurn.mode === "leaf"

                    // sweep: the page slides across the screen
                    Rectangle {
                        visible: win.sweep
                        width: win.width; height: win.height
                        x: PageTurn.phase <= 1 ? win.width * (1 - PageTurn.phase) : -win.width * (PageTurn.phase - 1)
                        color: PageTurn.pageColor
                        Rectangle { width: 3; height: parent.height; color: Theme.rule }   // the turning edge
                    }

                    // ink: a square grows from the toggle button
                    Rectangle {
                        visible: !win.sweep
                        readonly property bool mine: PageTurn.originScreen === sc.modelData.name && PageTurn.originX >= 0
                        readonly property real cx: mine ? PageTurn.originX : win.width / 2
                        readonly property real cy: mine ? PageTurn.originY : win.height / 2
                        readonly property real reach: 2 * Math.max(Math.max(cx, win.width - cx), Math.max(cy, win.height - cy))
                        readonly property real t: PageTurn.phase <= 1 ? PageTurn.phase : 2 - PageTurn.phase
                        width: reach * t; height: width
                        x: cx - width / 2; y: cy - height / 2
                        color: PageTurn.pageColor
                    }
                }
            }
        }
    }
}
