import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

// Percentage bar for sound and light. The window exists only for ~1.6 s and is small and
// click-through, so it can never get in the way.
Variants {
    model: Quickshell.screens

    Scope {
        id: sc
        required property var modelData

        LazyLoader {
            active: Osd.shown && Osd.screenName === sc.modelData.name

            PanelWindow {
                screen: sc.modelData
                color: "transparent"
                mask: Region {}
                exclusionMode: ExclusionMode.Ignore
                anchors { bottom: true }
                margins.bottom: 70
                implicitWidth: 320; implicitHeight: 76
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "rice-osd"

                Rectangle {
                    anchors.fill: parent
                    color: Theme.paper
                    border { width: 1; color: Theme.ink }

                    Txt { x: 18; y: 12; text: Osd.label; font.pixelSize: 16; color: Theme.muted }
                    Txt { anchors { right: parent.right; rightMargin: 18 } y: 4; font.pixelSize: 34
                          text: Math.round(Osd.value); color: Osd.dim ? Theme.muted : Theme.ink }
                    Rectangle { x: 18; y: 54; width: parent.width - 36; height: 8; color: Theme.rule }
                    Rectangle { x: 18; y: 54; height: 8; color: Osd.dim ? Theme.muted : Theme.ink
                                width: (parent.width - 36) * Math.max(0, Math.min(1, Osd.value / 100)) }
                }
            }
        }
    }
}
