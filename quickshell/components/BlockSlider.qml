import QtQuick
import qs

// Full-width block slider (Sound, Light). The filled part is ink, the rest is block.
// The label and value switch colour where the fill ends, so they stay readable.
Item {
    id: root
    property string label: ""
    property real value: 0            // 0..100
    signal moved(real value)
    implicitWidth: 274; implicitHeight: 32

    readonly property real fill: Math.max(0, Math.min(1, value / 100)) * width

    Rectangle { anchors.fill: parent; color: Theme.block }
    Rectangle { width: root.fill; height: parent.height; color: Theme.ink }

    component Labels: Item {
        property color tint
        width: root.width; height: root.height
        Txt { x: 11; anchors.verticalCenter: parent.verticalCenter; text: root.label; color: parent.tint; font.pixelSize: 16 }
        Mono { anchors { right: parent.right; rightMargin: 11; verticalCenter: parent.verticalCenter }
               text: Math.round(root.value); color: parent.tint; font.pixelSize: 11 }
    }

    Item {   // over the fill
        width: root.fill; height: parent.height; clip: true
        Labels { tint: Theme.paper }
    }
    Item {   // over the empty track
        x: root.fill; width: root.width - root.fill; height: parent.height; clip: true
        Labels { x: -root.fill; tint: Theme.ink }
    }

    Bracket { active: area.containsMouse; color: Theme.muted }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        function set(mx) { root.moved(Math.round(Math.max(0, Math.min(1, mx / root.width)) * 100)) }
        onPressed: mouse => set(mouse.x)
        onPositionChanged: mouse => { if (pressed) set(mouse.x) }
    }
}
