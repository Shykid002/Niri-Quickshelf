import QtQuick
import qs
import qs.components
import qs.services

// Design 4, "Grid": nine blocks; the middle one is today.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    function col(n) {
        return n === "cover" ? Theme.cover : n === "indigo" ? Theme.indigo : n === "ochre" ? Theme.ochre
             : n === "pine" ? Theme.pine : n === "ink" ? Theme.ink : Theme.block;
    }
    readonly property var cells: ["cover", "block", "indigo", "ochre", "ink", "block", "block", "pine", "cover"]

    Txt { x: 140 * root.u; y: 330 * root.u - baselineOffset; text: Almanac.monthName; font.pixelSize: 150 * root.u }
    Txt { x: 144 * root.u; y: 384 * root.u - baselineOffset; text: Almanac.roman; font.pixelSize: 26 * root.u; color: Theme.muted }
    Rectangle { x: 144 * root.u; y: 414 * root.u; width: 112 * root.u; height: 1; color: Theme.ink }
    Txt { x: 144 * root.u; y: 452 * root.u - baselineOffset; text: Almanac.weekday + ", " + Almanac.dateWords.replace("The ", "")
          font.pixelSize: 20 * root.u; color: Theme.muted }

    Grid {
        x: root.width - width - 130 * root.u; y: 175 * root.u
        columns: 3; spacing: 10 * root.u
        Repeater {
            model: 9
            delegate: Rectangle {
                id: cell
                required property int index
                width: 170 * root.u; height: 170 * root.u
                color: root.col(root.cells[index])
                Txt { visible: cell.index === 4; x: 14 * root.u; anchors.bottom: parent.bottom; anchors.bottomMargin: 8 * root.u
                      text: Almanac.numeral; font.pixelSize: 96 * root.u; color: Theme.paper
                      font.features: ({ "onum": 1, "pnum": 1 }) }
            }
        }
    }
    Txt { x: 144 * root.u; y: 800 * root.u; text: Almanac.coverNo; font.pixelSize: 15 * root.u; color: Theme.muted }
}
