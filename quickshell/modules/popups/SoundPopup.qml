import QtQuick
import Quickshell.Services.Pipewire
import qs
import qs.components
import qs.services

// Sound card, opened from the volume item: big level, mute switch, output list, playing apps.
PopupFrame {
    id: root

    // ── header block ──
    Rectangle {
        width: parent.width; height: 90; color: Theme.block

        Txt {
            id: big
            x: 16; anchors.verticalCenter: parent.verticalCenter
            text: Math.round(Audio.volume * 100)
            font.pixelSize: 58
            color: Audio.muted ? Theme.muted : Theme.ink
        }
        Item {
            anchors { left: big.right; leftMargin: 16; right: parent.right; rightMargin: 22; top: parent.top; bottom: parent.bottom }

            Txt { x: 0; y: 12; text: "Sound"; font.pixelSize: 17 }
            SquareToggle {
                anchors { right: parent.right; top: parent.top; topMargin: 15 }
                selfToggle: false
                checked: !Audio.muted
                onToggled: v => Audio.setMuted(!v)
            }
            Txt {
                x: 0; y: 38; width: parent.width
                text: Audio.sinkName; color: Theme.muted; font.pixelSize: 12; elide: Text.ElideRight
            }
            Item {   // volume bar
                id: bar
                x: 0; width: parent.width; height: 8
                anchors { bottom: parent.bottom; bottomMargin: 16 }
                Rectangle { anchors.fill: parent; color: Theme.rule }
                Rectangle { width: parent.width * Math.max(0, Math.min(1, Audio.volume)); height: parent.height; color: Theme.ink }
                MouseArea { cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor;
                    anchors { fill: parent; topMargin: -8; bottomMargin: -8 }
                    function set(mx) { Audio.setVolume(mx / bar.width * 100) }
                    onPressed: mouse => set(mouse.x)
                    onPositionChanged: mouse => { if (pressed) set(mouse.x) }
                }
            }
        }
    }

    // ── outputs ──
    Txt { x: 22; topPadding: 12; bottomPadding: 4; text: "Output"; color: Theme.muted; font.pixelSize: 12 }
    Repeater {
        model: Audio.sinks
        delegate: ListRow {
            id: out
            required property var modelData
            readonly property bool current: out.modelData === Audio.sink
            onClicked: Audio.setDefault(out.modelData)
            Square { x: 22; anchors.verticalCenter: parent.verticalCenter; filled: out.current }
            Txt { x: 50; anchors.verticalCenter: parent.verticalCenter; text: Audio.label(out.modelData)
                  elide: Text.ElideRight; width: parent.width - 130; font.pixelSize: 14 }
            Txt { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
                  visible: out.current; text: "in use"; color: Theme.muted; font.pixelSize: 12 }
        }
    }
    Item { width: parent.width; height: 8 }
    Rectangle { width: parent.width; height: 1; color: Theme.rule }

    // ── applications ──
    Txt { x: 22; topPadding: 12; bottomPadding: 4; text: "Applications"; color: Theme.muted; font.pixelSize: 12 }
    Txt { x: 22; visible: Audio.streams.length === 0; text: "Nothing is playing."; color: Theme.muted; font.pixelSize: 14
          height: visible ? 28 : 0 }
    Repeater {
        model: Audio.streams
        delegate: Item {
            id: app
            required property var modelData
            width: parent.width; height: 32
            BlockSlider {
                x: 22; width: parent.width - 44; height: 26; anchors.verticalCenter: parent.verticalCenter
                label: Audio.appName(app.modelData)
                value: app.modelData.audio ? app.modelData.audio.volume * 100 : 0
                onMoved: v => { if (app.modelData.audio) app.modelData.audio.volume = v / 100 }
            }
        }
    }
    Item { width: parent.width; height: 12 }
}
