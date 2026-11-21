import QtQuick
import qs

// Print-registration corner. corner: "tl" draws ┌, "br" draws ┘.
Item {
    id: root
    property string corner: "tl"
    property real arm: 21
    property real weight: 1
    property color color: Theme.muted
    width: arm; height: arm

    Rectangle {   // horizontal arm
        width: root.arm; height: root.weight; color: root.color
        anchors { top: root.corner === "tl" ? parent.top : undefined
                  bottom: root.corner === "br" ? parent.bottom : undefined }
    }
    Rectangle {   // vertical arm
        width: root.weight; height: root.arm; color: root.color
        anchors { left: root.corner === "tl" ? parent.left : undefined
                  right: root.corner === "br" ? parent.right : undefined }
    }
}
