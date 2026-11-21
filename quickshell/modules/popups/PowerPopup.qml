import QtQuick
import qs
import qs.components
import qs.services

// Opened from the battery item: charge, state, and the four power profiles. The chosen one is active.
PopupFrame {
    id: root
    implicitWidth: 320

    Item {
        width: parent.width; height: 66
        Txt { x: 22; y: 12; text: "Battery"; font.pixelSize: 17 }
        Mono { anchors { right: parent.right; rightMargin: 22; top: parent.top; topMargin: 15 }
               text: Battery.percent + "%"; font.pixelSize: 14; font.bold: true; color: Battery.tone }
        Txt { x: 22; y: 38; text: Battery.status; color: Theme.muted; font.pixelSize: 12 }
    }
    Rectangle { width: parent.width; height: 1; color: Theme.rule }
    Item { width: parent.width; height: 6 }

    Repeater {
        model: Power.profiles
        delegate: ListRow {
            id: prof
            required property var modelData
            readonly property bool active: Power.active === modelData.id
            readonly property bool off: modelData.id === "performance" && !Power.hasPerformance
            rowHeight: 36
            onClicked: Power.choose(modelData.id)
            Square { x: 22; anchors.verticalCenter: parent.verticalCenter; filled: prof.active }
            Txt { x: 50; anchors.verticalCenter: parent.verticalCenter; text: prof.modelData.label; font.pixelSize: 15
                  color: prof.off ? Theme.muted : Theme.ink }
            Txt { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
                  text: prof.active ? "active" : prof.off ? "not available" : prof.modelData.note
                  color: Theme.muted; font.pixelSize: 12 }
        }
    }
    Item { width: parent.width; height: 8 }
}
