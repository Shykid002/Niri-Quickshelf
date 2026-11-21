import QtQuick
import qs
import qs.services

// One pill per workspace: long ink = focused, grey square = has windows, hollow = empty.
Row {
    spacing: 5
    Repeater {
        model: Niri.workspaces
        delegate: Item {
            id: pill
            required property var modelData
            width: modelData.focused ? 22 : 7
            height: 27

            Rectangle {
                anchors.centerIn: parent
                width: parent.width; height: 7
                color: pill.modelData.focused ? Theme.ink : pill.modelData.occupied ? Theme.muted : "transparent"
                border { width: (pill.modelData.focused || pill.modelData.occupied) ? 0 : 1; color: Theme.muted }
            }
            MouseArea { cursorShape: Qt.PointingHandCursor; anchors.fill: parent; onClicked: Niri.focusWorkspace(pill.modelData.idx) }
        }
    }
}
