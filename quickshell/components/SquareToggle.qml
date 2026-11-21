import QtQuick
import qs

// Square switch, 28x14: a thin frame with a square knob that sits right when on.
Item {
    id: root
    property bool checked: false
    property bool selfToggle: true      // false = state is bound from outside; only emits toggled()
    signal toggled(bool checked)
    implicitWidth: 28; implicitHeight: 14

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border { width: 1; color: Theme.ink }
    }
    Rectangle {
        width: 10; height: 10
        y: 2
        x: root.checked ? root.width - width - 2 : 2
        color: root.checked ? Theme.ink : Theme.muted
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.ArrowCursor
        onClicked: { const v = !root.checked; if (root.selfToggle) root.checked = v; root.toggled(v) }
    }
}
