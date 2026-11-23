import QtQuick
import qs
import qs.components
import qs.services

// Design 10, "Bauhaus": interlocking primary blocks & stacked year with active cover accent.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    // Left full-bleed spine band (follows active cover colour)
    Rectangle {
        x: 0; y: 0
        width: 56 * root.u; height: parent.height
        color: Theme.cover
    }

    // Left editorial column
    Column {
        x: 120 * root.u; y: 210 * root.u
        width: root.width * 0.34
        spacing: 18 * root.u

        Txt {
            text: Almanac.coverNo + "  ·  " + Almanac.roman
            font.pixelSize: 15 * root.u
            color: Theme.cover
            font.letterSpacing: 1.4
        }
        Txt {
            text: Almanac.weekday
            font.pixelSize: 74 * root.u
        }
        Txt {
            text: Almanac.dateWords
            font.pixelSize: 20 * root.u
            color: Theme.muted
        }
        Item { width: 1; height: 10 * root.u }
        Rectangle { width: 112 * root.u; height: 1; color: Theme.ink }
        Item { width: 1; height: 6 * root.u }
        Txt {
            visible: Prefs.verse
            width: parent.width
            wrapMode: Text.WordWrap
            lineHeight: 1.25
            text: Almanac.verse.text
            font.pixelSize: 19 * root.u
            color: Theme.muted
        }
    }

    // ── BAUHAUS POSTER COMPOSITION (RIGHT) ──────────────────
    Item {
        id: poster
        readonly property real bw: 540 * root.u
        readonly property real leftBarW: 88 * root.u
        readonly property real rightBarW: 88 * root.u
        readonly property real topH: 88 * root.u
        readonly property real centerH: 300 * root.u
        readonly property real bottomH: 88 * root.u

        x: root.width - bw - 120 * root.u
        y: 95 * root.u
        width: bw
        height: 710 * root.u

        // Bold title & dual sub-captions aligned above the ochre bar
        Txt {
            x: poster.leftBarW + 74 * root.u
            y: 92 * root.u - baselineOffset
            text: Almanac.monthName.toLowerCase()
            font.pixelSize: 68 * root.u
            font.bold: true
            font.letterSpacing: -1.0
        }
        Txt {
            x: poster.leftBarW + 76 * root.u
            y: 122 * root.u - baselineOffset
            text: "basic · niri"
            font.pixelSize: 13 * root.u
            font.bold: true
            color: Theme.ink
        }
        Txt {
            anchors.right: parent.right
            y: 122 * root.u - baselineOffset
            text: Almanac.weekday.toLowerCase()
            font.pixelSize: 13 * root.u
            font.bold: true
            color: Theme.ink
        }

        // 1. Tall vertical block (left, follows active cover colour)
        Rectangle {
            x: 0; y: 0
            width: poster.leftBarW
            height: 150 * root.u + poster.topH + poster.centerH
            color: Theme.cover
        }

        // 2. Horizontal Ochre lintel (top right)
        Rectangle {
            x: poster.leftBarW; y: 150 * root.u
            width: poster.bw - poster.leftBarW
            height: poster.topH
            color: Theme.ochre
        }

        // 3. Central Ink square with stacked numeral & year
        Rectangle {
            id: coreBlock
            x: poster.leftBarW; y: 150 * root.u + poster.topH
            width: poster.bw - poster.leftBarW - poster.rightBarW
            height: poster.centerH
            color: Theme.ink

            Column {
                anchors.centerIn: parent
                spacing: 4 * root.u
                Txt {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Almanac.coverNo
                    font.pixelSize: 28 * root.u
                    font.bold: true
                    color: Theme.paper
                }
                Txt {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: new Date().getFullYear().toString()
                    font.pixelSize: 28 * root.u
                    font.bold: true
                    color: Theme.paper
                }
            }
        }

        // 4. Lower Muted/Block plinth underneath Ink square
        Rectangle {
            x: poster.leftBarW
            y: 150 * root.u + poster.topH + poster.centerH
            width: poster.bw - poster.leftBarW - poster.rightBarW
            height: poster.bottomH
            color: Theme.block
        }

        // 5. Tall vertical Red column (bottom right)
        Rectangle {
            x: poster.bw - poster.rightBarW
            y: 150 * root.u + poster.topH
            width: poster.rightBarW
            height: poster.centerH + poster.bottomH
            color: Theme.red
        }

        // Bottom colophon stamp
        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 150 * root.u + poster.topH + poster.centerH + poster.bottomH + 34 * root.u - baselineOffset
            text: "EDITION " + Almanac.roman
            font.pixelSize: 15 * root.u
            font.bold: true
            font.letterSpacing: 1.5
        }
    }
}

