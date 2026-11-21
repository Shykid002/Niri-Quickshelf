import QtQuick
import Quickshell
import qs
import qs.components

// Phase 1 test surface: every Theme token. Click to flip the theme.
// Enable with:  RICE_THEME_TEST=1 qs -c rice
FloatingWindow {
        title: "rice · theme"
        implicitWidth: 560
        implicitHeight: 360
        color: Theme.paper

        MouseArea { anchors.fill: parent; onClicked: Theme.toggle() }

        Column {
            anchors { left: parent.left; top: parent.top; margins: 32 }
            spacing: 18

            Txt { text: Theme.dark ? "Ink" : "Paper"; font.pixelSize: 44 }
            Txt { text: "Click to turn the page"; color: Theme.muted }
            Mono { text: "Paper House  connected, good, 6 GHz" }

            Row {
                spacing: 8
                Repeater {
                    model: ["paper", "block", "ink", "muted", "rule", "red", "ochre", "indigo", "pine"]
                    delegate: Column {
                        spacing: 6
                        Rectangle {
                            width: 48; height: 48; color: Theme[modelData]
                            border { width: 1; color: Theme.rule }
                        }
                        Txt { text: modelData; font.pixelSize: 11; color: Theme.muted }
                    }
                }
            }
            Txt { text: "16  ·  MMXXVI  ·  11:38"; font.pixelSize: 22 }
        }
    }
