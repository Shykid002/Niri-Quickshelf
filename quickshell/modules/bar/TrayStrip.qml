import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs
import qs.components
import qs.services

// Tray button. The hollow square spins while any tray app is active.
// Hover expands it to show the running tray apps as icons (safeeyes, spotify, obs...).
//   click        : activate the app (or open its menu if it is menu-only)
//   right click  : open the app's menu
Item {
    id: root
    required property var window            // the PanelWindow, needed to anchor menus
    readonly property bool hovered: hover.hovered

    readonly property bool busy: {
        const v = SystemTray.items.values;
        for (let i = 0; i < v.length; i++) if (v[i].status !== Status.Passive) return true;
        return false;
    }

    implicitWidth: row.implicitWidth + 16
    implicitHeight: 27

    readonly property bool open: Popups.current === "tray" && Popups.screenName === window.screen.name
    HoverHandler { id: hover }
    Rectangle { anchors.fill: parent; color: Theme.ink; visible: root.open }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 12

        Glyph {
            kind: "tray"
            tone: root.open ? Theme.paper : Theme.ink
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors { fill: parent; margins: -8 }
                onClicked: Popups.toggle("tray", root.window.screen, root.window.width - root.mapToItem(null, root.width, 0).x)
            }
            RotationAnimation on rotation {
                running: root.busy; from: 0; to: 360; duration: 3200; loops: Animation.Infinite
            }
        }

        Repeater {
            model: SystemTray.items
            delegate: Item {
                id: entry
                required property var modelData
                visible: root.hovered
                width: 16
                height: 27

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 16
                    source: entry.modelData.icon
                    opacity: entry.modelData.status === Status.Passive ? 0.45 : 1.0
                }
                Bracket { active: entryArea.containsMouse
                          anchors.fill: undefined; x: -4; y: 2.5; width: 24; height: 22 }
                MouseArea {
                    id: entryArea
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: mouse => {
                        const it = entry.modelData;
                        const p = entry.mapToItem(null, 0, 27);
                        if (mouse.button === Qt.RightButton || (mouse.button === Qt.LeftButton && it.onlyMenu)) {
                            if (it.hasMenu) it.display(root.window, p.x, p.y);
                        } else if (mouse.button === Qt.MiddleButton) {
                            it.secondaryActivate();
                        } else {
                            it.activate();
                        }
                    }
                }
            }
        }
    }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 22
        Bracket { active: root.hovered; color: root.open ? Theme.paper : Theme.ink }
    }
}
