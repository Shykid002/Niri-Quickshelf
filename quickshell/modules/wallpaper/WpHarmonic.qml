import QtQuick
import qs
import qs.components
import qs.services

// Design 14, "Harmonic": asymmetric Swiss concert poster with stepped cover-colour bars.
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

    // ── STEPPED HARMONIC BARS POSTER CARD (RIGHT) ───────────
    Item {
        id: card
        x: root.width - width - 120 * root.u
        y: 85 * root.u
        width: 520 * root.u
        height: 730 * root.u
        clip: true

        Rectangle { anchors.fill: parent; color: Theme.block }

        // Top-left solid cover block
        Rectangle { x: 0; y: 0; width: 268 * root.u; height: 438 * root.u; color: Theme.cover }

        // Three stepped vertical bars on the right half
        Rectangle { x: 270 * root.u; y: 170 * root.u; width: 132 * root.u; height: 435 * root.u; color: Theme.cover }
        Rectangle { x: 404 * root.u; y: 292 * root.u; width: 66 * root.u;  height: 438 * root.u; color: Theme.cover }
        Rectangle { x: 472 * root.u; y: 105 * root.u; width: 32 * root.u;  height: 435 * root.u; color: Theme.cover }
        Rectangle { x: 506 * root.u; y: 0;            width: 14 * root.u;  height: 438 * root.u; color: Theme.cover }

        // Left-aligned Swiss concert typography inside top-left block
        Column {
            x: 112 * root.u; y: 215 * root.u
            spacing: 2 * root.u
            Txt { text: Almanac.weekday.toLowerCase();   font.pixelSize: 21 * root.u; color: Theme.ink }
            Txt { text: Almanac.monthName.toLowerCase(); font.pixelSize: 21 * root.u; color: Theme.ink }
            Txt { text: Almanac.roman.toLowerCase();     font.pixelSize: 21 * root.u; color: Theme.ink }
            Txt { text: Almanac.coverNo.toLowerCase();   font.pixelSize: 21 * root.u; color: Theme.ink }
            Txt { text: "paper & ink";                   font.pixelSize: 21 * root.u; color: Theme.ink }
        }

        // Lower-left program metadata
        Column {
            x: 112 * root.u; y: 446 * root.u
            width: 150 * root.u
            spacing: 8 * root.u
            Txt { text: Almanac.dateWords.toLowerCase() + "\n" + Almanac.year; font.pixelSize: 11 * root.u; color: Theme.ink }
            Txt {
                visible: Prefs.verse; width: parent.width; wrapMode: Text.WordWrap; lineHeight: 1.2
                text: Almanac.verse.text.toLowerCase() + "\n— " + Almanac.verse.by.toLowerCase()
                font.pixelSize: 10.5 * root.u; color: Theme.ink
            }
        }
    }
}

