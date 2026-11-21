import QtQuick
import qs
import qs.components
import qs.services

// Opened from the bar's notification item. View = open the full list in the Day tab. Clear = dismiss all.
PopupFrame {
    id: root

    Item {
        width: parent.width; height: 45
        Txt { x: 22; anchors.verticalCenter: parent.verticalCenter; text: "Notifications"; font.pixelSize: 17 }
        Mono { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
               text: Notifs.count; color: Theme.muted; font.pixelSize: 12 }
    }
    Item {
        width: parent.width; height: 34
        Row {
            x: 22; anchors.verticalCenter: parent.verticalCenter; spacing: 30
            Repeater {
                model: ["View", "Clear"]
                delegate: Item {
                    id: act
                    required property string modelData
                    readonly property bool off: modelData === "Clear" && Notifs.count === 0
                    width: lbl.implicitWidth; height: 26
                    Txt { id: lbl; anchors.verticalCenter: parent.verticalCenter; text: act.modelData
                          color: act.off ? Theme.muted : Theme.ink }
                    Item { anchors { fill: parent; margins: -6 } Bracket { active: aArea.containsMouse && !act.off } }
                    MouseArea {
                        id: aArea; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (act.modelData === "View") Drawer.openOn("day", Popups.screenName);
                            else Notifs.clearAll();
                        }
                    }
                }
            }
        }
    }
    Rectangle { width: parent.width; height: 1; color: Theme.rule }

    Txt { visible: Notifs.conflict; x: 22; width: parent.width - 44; wrapMode: Text.WordWrap; topPadding: 10; bottomPadding: 10
          text: "Notifications are being handled by " + Notifs.owner + ". Stop it to receive them here."
          color: Theme.red; font.pixelSize: 12; height: visible ? implicitHeight : 0 }
    Txt { visible: Notifs.count === 0 && !Notifs.conflict; x: 22; text: "Nothing waiting"; color: Theme.muted; height: visible ? 44 : 0 }
    Repeater {
        model: Notifs.newest.slice(0, 4)
        delegate: NoteRow { required property var modelData; note: modelData }
    }
    Txt { visible: Notifs.count > 4; x: 22; height: visible ? 30 : 0
          text: "+" + (Notifs.count - 4) + " more, in View"; color: Theme.muted; font.pixelSize: 12 }
    Item { width: parent.width; height: 8 }
}
