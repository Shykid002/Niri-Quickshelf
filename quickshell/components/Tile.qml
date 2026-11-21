import QtQuick
import qs

// Quick-setting tile (Wi-Fi, Bluetooth, Ink, Quiet).
// On: solid accent with a filled corner square. Off: block colour with a hollow one.
Item {
    id: root
    property string title: ""
    property string detail: ""        // literal string, shown in the monospace face
    property bool on: false
    property color accent: Theme.pine
    property int titleSize: 16
    signal clicked()
    implicitWidth: 90; implicitHeight: 60

    readonly property color fg: on ? Theme.paper : Theme.ink

    Rectangle { anchors.fill: parent; color: root.on ? root.accent : Theme.block }

    Square {
        anchors { top: parent.top; right: parent.right; topMargin: 9; rightMargin: 9 }
        width: 6; height: 6
        filled: root.on; tone: root.fg
    }
    Column {
        anchors { left: parent.left; bottom: parent.bottom; leftMargin: 11; bottomMargin: 9 }
        spacing: 1
        Txt { text: root.title; color: root.fg; font.pixelSize: root.titleSize }
        Mono { visible: root.detail !== ""; text: root.detail; color: root.fg; font.pixelSize: 10
               elide: Text.ElideRight; width: Math.min(implicitWidth, root.width - 22) }
    }

    Bracket { active: area.containsMouse; color: root.fg }
    MouseArea { cursorShape: Qt.PointingHandCursor; id: area; anchors.fill: parent; hoverEnabled: true; onClicked: root.clicked() }
}
