import QtQuick
import qs

// A 30px clickable row with hover brackets. Put content inside it.
Item {
    id: root
    default property alias content: inner.data
    property real rowHeight: 30
    signal clicked()
    width: parent ? parent.width : 0
    height: visible ? rowHeight : 0

    Item { id: inner; anchors.fill: parent }
    Item {
        anchors { fill: parent; leftMargin: 12; rightMargin: 12; topMargin: 2; bottomMargin: 2 }
        Bracket { active: area.containsMouse }
    }
    MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
}
