import QtQuick
import qs
import qs.services

// One notification: a small colour box, app, summary, body, and the time it arrived.
// Click to expand the body. On hover the time turns into "clear".
Item {
    id: root
    required property var note
    property real pad: 22
    property bool expanded: false
    readonly property bool hot: area.containsMouse || clearArea.containsMouse
    width: parent ? parent.width : 0
    height: implicitHeight
    implicitHeight: col.implicitHeight + 14

    Rectangle {   // this notification's own box
        x: root.pad; y: 12; width: 8; height: 8
        color: Notifs.colorOf(root.note)
    }
    Column {
        id: col
        x: root.pad + 16; y: 7
        width: root.width - 2 * root.pad - 16 - 50
        spacing: 1
        Txt { text: root.note.appName; color: Theme.muted; font.pixelSize: 11; width: parent.width; elide: Text.ElideRight }
        Txt { text: root.note.summary; font.pixelSize: 15; width: parent.width
              textFormat: Text.PlainText
              wrapMode: root.expanded ? Text.Wrap : Text.NoWrap; elide: root.expanded ? Text.ElideNone : Text.ElideRight }
        Txt { visible: text !== ""; text: Notifs.strip(root.note.body); color: Theme.muted; font.pixelSize: 12; width: parent.width
              textFormat: Text.PlainText; wrapMode: Text.Wrap
              maximumLineCount: root.expanded ? 30 : 2; elide: Text.ElideRight }
    }

    Item {
        anchors { fill: parent; leftMargin: Math.max(root.pad - 10, 0); rightMargin: Math.max(root.pad - 10, 0); topMargin: 2; bottomMargin: 2 }
        Bracket { active: root.hot }
    }
    MouseArea { cursorShape: Qt.PointingHandCursor; id: area; anchors.fill: parent; hoverEnabled: true; onClicked: root.expanded = !root.expanded }

    Mono {   // arrival time
        anchors { right: parent.right; rightMargin: Math.max(root.pad, 8); top: parent.top; topMargin: 9 }
        visible: !root.hot
        text: Notifs.timeText(root.note); color: Theme.muted; font.pixelSize: 11
    }
    Txt {
        anchors { right: parent.right; rightMargin: Math.max(root.pad, 8); top: parent.top; topMargin: 8 }
        visible: root.hot
        text: "clear"; color: Theme.muted; font.pixelSize: 12
        MouseArea { cursorShape: Qt.PointingHandCursor; id: clearArea; anchors { fill: parent; margins: -6 } hoverEnabled: true; onClicked: root.note.dismiss() }
    }
}
