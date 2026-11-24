import QtQuick
import qs
import qs.components
import qs.services

// Design 2, "Spines": a shelf of book spines in the palette colours, bottom-aligned.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    function col(n) {
        return n === "cover" ? Theme.cover : n === "indigo" ? Theme.indigo : n === "ochre" ? Theme.ochre
             : n === "pine" ? Theme.pine : n === "ink" ? Theme.ink : n === "red" ? Theme.red : Theme.block;
    }
    readonly property var names:  ["cover", "indigo", "block", "ochre", "ink", "pine", "block", "red", "indigo"]
    readonly property var widths: [70, 96, 58, 110, 76, 90, 64, 100, 72]
    readonly property var heights:[520, 430, 610, 380, 560, 470, 590, 420, 540]
    readonly property var labels: [Almanac.coverNo, "", Almanac.monthName, "", Almanac.roman, Almanac.weekday, "", "", ""]

    Txt { x: 120 * root.u; y: 150 * root.u - baselineOffset; text: Almanac.weekday; font.pixelSize: 78 * root.u }
    Txt { x: 120 * root.u; y: 196 * root.u - baselineOffset; text: Almanac.dateWords; font.pixelSize: 22 * root.u; color: Theme.muted }
    Rectangle { x: 120 * root.u; y: 226 * root.u; width: 112 * root.u; height: 1; color: Theme.ink }

    Column {
        visible: Prefs.verse
        x: 120 * root.u
        y: 256 * root.u
        width: Math.max(220 * root.u, shelf.x - x - 48 * root.u)
        spacing: 8 * root.u

        Txt {
            width: parent.width
            wrapMode: Text.WordWrap
            lineHeight: 1.28
            text: "“" + Almanac.verse.text + "”"
            font.pixelSize: 20 * root.u
            color: Theme.ink
        }
        Txt {
            width: parent.width
            wrapMode: Text.WordWrap
            text: "— " + Almanac.verse.by
            font.pixelSize: 15 * root.u
            font.italic: true
            color: Theme.muted
        }
    }

    Row {
        id: shelf
        spacing: 10 * root.u
        x: root.width - width - 110 * root.u
        y: 800 * root.u - height
        height: 620 * root.u
        Repeater {
            model: 9
            delegate: Item {
                id: sp
                required property int index
                width: root.widths[index] * root.u
                height: shelf.height
                Rectangle {
                    width: parent.width; height: root.heights[sp.index] * root.u
                    anchors.bottom: parent.bottom
                    color: root.col(root.names[sp.index])
                    Txt {
                        visible: root.labels[sp.index] !== ""
                        text: root.labels[sp.index]; font.pixelSize: 17 * root.u
                        color: Theme.paper
                        rotation: -90; transformOrigin: Item.TopLeft
                        x: (parent.width - implicitHeight) / 2; y: parent.height - 22 * root.u
                    }
                }
            }
        }
    }
    Rectangle { x: 90 * root.u; y: 800 * root.u; width: root.width - 180 * root.u; height: 1; color: Theme.ink }   // the shelf
    Txt { x: 120 * root.u; y: 830 * root.u; text: "basic · niri"; font.pixelSize: 14 * root.u; color: Theme.muted }
}

