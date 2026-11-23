import QtQuick
import qs
import qs.components
import qs.services

// Design 6, "Index": editorial table-of-contents layout.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    CropMark { corner: "tl"; x: 61 * root.u; y: 89 * root.u; arm: 21 * root.u }
    CropMark { corner: "tr"; x: root.width - 61 * root.u - width; y: 89 * root.u; arm: 21 * root.u }

    // Top cover accent bar
    Rectangle { x: 140 * root.u; y: 140 * root.u; width: 64 * root.u; height: 8 * root.u; color: Theme.cover }

    Txt {
        x: 140 * root.u; y: 240 * root.u - baselineOffset
        text: Almanac.weekday
        font.pixelSize: 88 * root.u
    }

    // Ruled ledger rows
    Column {
        x: 140 * root.u; y: 310 * root.u
        width: root.width - 280 * root.u
        spacing: 22 * root.u

        Repeater {
            model: [
                { label: "DATE",    val: Almanac.dateWords },
                { label: "EDITION", val: Almanac.coverNo + " · " + Almanac.roman },
                { label: "MODE",    val: Theme.dark ? "INK / DARK" : "PAPER / LIGHT" }
            ]
            delegate: Item {
                required property var modelData
                width: parent.width; height: 34 * root.u
                Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: Theme.rule }
                Txt { y: 10 * root.u; text: modelData.label; font.pixelSize: 13 * root.u; color: Theme.muted; font.letterSpacing: 1.5 }
                Txt { anchors.right: parent.right; y: 8 * root.u; text: modelData.val; font.pixelSize: 18 * root.u }
            }
        }
    }

    // Large numeral anchored bottom-right
    Txt {
        anchors.right: parent.right; anchors.rightMargin: 140 * root.u
        y: 800 * root.u - baselineOffset
        text: Almanac.numeral
        font.pixelSize: 220 * root.u
        color: Theme.cover
        font.features: ({ "onum": 1, "pnum": 1 })
    }
}

