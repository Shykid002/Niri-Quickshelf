import QtQuick
import qs
import qs.components
import qs.services

// Design 7, "Colophon": a printer's specimen block with a vertical cover band and rules.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    // four-corner printer's trim marks
    CropMark { corner: "tl"; x: 61 * root.u; y: 89 * root.u; arm: 21 * root.u }
    CropMark { corner: "tr"; x: root.width - 61 * root.u - width; y: 89 * root.u; arm: 21 * root.u }
    CropMark { corner: "bl"; x: 61 * root.u; y: root.height - 61 * root.u - height; arm: 21 * root.u }
    CropMark { corner: "br"; x: root.width - 61 * root.u - width; y: root.height - 61 * root.u - height; arm: 21 * root.u }

    // subtle left-of-center vertical spine rule + cover swatch
    Rectangle {
        x: 240 * root.u; y: 140 * root.u
        width: 1; height: root.height - 280 * root.u
        color: Theme.rule
    }
    Rectangle {
        x: 240 * root.u - 18 * root.u; y: 210 * root.u
        width: 36 * root.u; height: 140 * root.u
        color: Theme.cover
    }

    // main specimen column
    Column {
        x: 310 * root.u; y: 210 * root.u
        width: root.width - 470 * root.u
        spacing: 18 * root.u

        Txt {
            text: Almanac.coverNo + "   ·   " + Almanac.roman
            font.pixelSize: 16 * root.u
            color: Theme.cover
            font.letterSpacing: 1.2
        }

        Txt {
            text: Almanac.monthName + " " + Almanac.numeral
            font.pixelSize: 84 * root.u
            font.features: ({ "onum": 1, "pnum": 1 })
        }

        Txt {
            text: Almanac.weekday + " — " + Almanac.dateWords
            font.pixelSize: 21 * root.u
            color: Theme.muted
        }

        Item { width: 1; height: 10 * root.u }
        Rectangle { width: 140 * root.u; height: 1; color: Theme.ink }
        Item { width: 1; height: 10 * root.u }

        // four-colour ink registration bar
        Row {
            spacing: 10 * root.u
            Repeater {
                model: [Theme.indigo, Theme.red, Theme.pine, Theme.ochre]
                delegate: Rectangle {
                    required property var modelData
                    width: 22 * root.u; height: 22 * root.u
                    color: modelData
                }
            }
        }

        Txt {
            visible: Prefs.verse
            width: parent.width * 0.85
            wrapMode: Text.WordWrap
            lineHeight: 1.25
            text: Almanac.verse.text + (Almanac.verse.by ? "  —  " + Almanac.verse.by : "")
            font.pixelSize: 18 * root.u
            color: Theme.muted
        }
    }

    // bottom colophon stamp
    Txt {
        x: 310 * root.u; y: 800 * root.u - baselineOffset
        text: "set in eb garamond & monaspace xenon   ·   basic · niri"
        font.pixelSize: 13 * root.u
        color: Theme.muted
        font.letterSpacing: 0.6
    }
}

