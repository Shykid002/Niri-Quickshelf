import QtQuick
import qs

// Hover / selection marker: a corner tick at top-left and bottom-right of the parent.
// Reference frames: 22px tall items, 4px arms, 1px stroke. Replaces fills for hover.
Item {
    id: root
    property bool active: false
    property real arm: 4
    property color color: Theme.ink
    anchors.fill: parent
    visible: active

    CropMark { corner: "tl"; arm: root.arm; color: root.color; x: 0; y: 0 }
    CropMark { corner: "br"; arm: root.arm; color: root.color; x: root.width - root.arm; y: root.height - root.arm }
}
