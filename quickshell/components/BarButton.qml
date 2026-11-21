import QtQuick
import qs

// A bar item. Hover shows corner brackets. `open` (its popup/drawer is showing)
// inverts it: ink block, paper glyph. Put glyphs/text inside; give them tone: button.tone.
Item {
    id: root
    default property alias content: row.data
    property bool open: false
    readonly property bool hovered: area.containsMouse
    readonly property color tone: open ? Theme.paper : Theme.ink
    signal clicked()

    implicitWidth: row.implicitWidth + 16
    implicitHeight: 27

    Rectangle { anchors.fill: parent; color: Theme.ink; visible: root.open }
    Row { id: row; anchors.centerIn: parent; spacing: 6 }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 22
        Bracket { active: root.hovered; color: root.tone }
    }
    MouseArea { cursorShape: Qt.PointingHandCursor; id: area; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
}
