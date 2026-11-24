import QtQuick
import qs
import qs.components
import qs.services

// Design 13, "Brockmann": orthogonal Swiss typographic grid with 90-degree rotated display type.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    Column {
        x: 110 * root.u; y: 210 * root.u
        width: root.width * 0.34
        spacing: 18 * root.u

        Txt { text: Almanac.numeral; font.pixelSize: 160 * root.u; font.features: ({ "onum": 1, "pnum": 1 }) }
        Rectangle { width: 112 * root.u; height: 1; color: Theme.ink }
        Txt { text: Almanac.weekday + ", " + Almanac.dateWords.replace("The ", ""); font.pixelSize: 21 * root.u; color: Theme.muted }
        Column {
            visible: Prefs.verse
            width: parent.width
            spacing: 6 * root.u
            Txt {
                width: parent.width
                wrapMode: Text.WordWrap
                lineHeight: 1.25
                text: "“" + Almanac.verse.text + "”"
                font.pixelSize: 19 * root.u
                color: Theme.ink
            }
            Txt {
                text: "— " + Almanac.verse.by
                font.pixelSize: 15 * root.u
                font.italic: true
                color: Theme.muted
            }
        }
    }

    // ── ORTHOGONAL TYPOGRAPHIC GRID POSTER CARD (RIGHT) ─────
    Item {
        id: card
        x: root.width - width - 120 * root.u
        y: 85 * root.u
        width: 520 * root.u
        height: 730 * root.u
        clip: true

        Rectangle { anchors.fill: parent; color: Theme.block }

        // 4 x 5 Swiss hairline grid
        Repeater {
            model: [0.25, 0.50, 0.75]
            delegate: Rectangle {
                required property real modelData
                x: card.width * modelData; y: 0; width: 1; height: card.height
                color: Theme.rule
            }
        }
        Repeater {
            model: [0.22, 0.45, 0.64, 0.82]
            delegate: Rectangle {
                required property real modelData
                x: 0; y: card.height * modelData; width: card.width; height: 1
                color: Theme.rule
            }
        }

        // Rotated vertical left display word (Weekday)
        Txt {
            text: Almanac.weekday
            font.pixelSize: 56 * root.u
            font.bold: true
            color: Theme.ink
            rotation: -90
            transformOrigin: Item.TopLeft
            x: card.width * 0.25 - 64 * root.u
            y: card.height * 0.64 - 8 * root.u
        }

        // Center micro-typography block (The Grid System / Verse)
        Column {
            x: card.width * 0.50 + 6 * root.u
            y: card.height * 0.45 + 6 * root.u
            width: card.width * 0.23
            spacing: 4 * root.u
            Txt { text: "the grid system"; font.pixelSize: 12 * root.u; font.bold: true; color: Theme.cover }
            Txt {
                width: parent.width; wrapMode: Text.WordWrap; lineHeight: 1.15
                text: Prefs.verse ? Almanac.verse.text : (Almanac.coverNo + " · " + Almanac.roman)
                font.pixelSize: 9.5 * root.u; color: Theme.ink
            }
        }

        // Rotated vertical right monumental display word (Month)
        Txt {
            text: Almanac.monthName
            font.pixelSize: 98 * root.u
            font.bold: true
            color: Theme.ink
            rotation: -90
            transformOrigin: Item.TopLeft
            x: card.width * 0.75 - 4 * root.u
            y: card.height * 0.82 - 8 * root.u
        }

        // Horizontal bottom monumental word (Roman Year)
        Txt {
            text: Almanac.roman
            font.pixelSize: 92 * root.u
            font.bold: true
            color: Theme.cover
            x: card.width * 0.25 - 4 * root.u
            y: card.height * 0.82 - 12 * root.u
        }
    }
}

