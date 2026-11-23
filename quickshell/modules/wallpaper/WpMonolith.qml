import QtQuick
import qs
import qs.components
import qs.services

// Design 9, "Monolith": architectural elevation with a tall tonal column and cover beacon.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    // Subtle full-bleed architectural grid lines
    Rectangle { x: root.width * 0.64; y: 0; width: 1; height: parent.height; color: Theme.rule; opacity: 0.55 }
    Rectangle { x: 0; y: 660 * root.u; width: parent.width; height: 1; color: Theme.rule; opacity: 0.55 }

    // Tall architectural monolith block on the right
    Rectangle {
        id: monolith
        x: root.width * 0.64 + 1
        y: 110 * root.u
        width: 260 * root.u
        height: 550 * root.u
        color: Theme.block

        // Cover-colour lintel bar across the top of the monolith
        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 14 * root.u
            color: Theme.cover
        }

        // Recessed inner frame
        Rectangle {
            anchors.fill: parent
            anchors.margins: 28 * root.u
            anchors.topMargin: 42 * root.u
            color: "transparent"
            border { width: 1; color: Theme.rule }
        }

        // Giant numeral cropped cleanly inside the monolith
        Txt {
            x: 24 * root.u
            y: parent.height - 34 * root.u - baselineOffset
            text: Almanac.numeral
            font.pixelSize: 170 * root.u
            color: Theme.ink
            font.features: ({ "onum": 1, "pnum": 1 })
        }
    }

    // Small contrasting square overlapping the monolith's base-left corner
    Rectangle {
        x: monolith.x - 16 * root.u
        y: 660 * root.u - 16 * root.u
        width: 32 * root.u; height: 32 * root.u
        color: Theme.cover
    }

    // Left-hand typographic elevation
    Column {
        x: 140 * root.u
        y: 230 * root.u
        width: root.width * 0.64 - 200 * root.u
        spacing: 18 * root.u

        Txt {
            text: Almanac.coverNo + "  /  " + Almanac.roman
            font.pixelSize: 15 * root.u
            color: Theme.cover
            font.letterSpacing: 1.4
        }

        Txt {
            text: Almanac.weekday
            font.pixelSize: 82 * root.u
        }

        Txt {
            text: Almanac.dateWords
            font.pixelSize: 22 * root.u
            color: Theme.muted
        }

        Item { width: 1; height: 14 * root.u }
        Rectangle { width: 120 * root.u; height: 1; color: Theme.ink }
        Item { width: 1; height: 8 * root.u }

        Txt {
            visible: Prefs.verse
            width: parent.width
            wrapMode: Text.WordWrap
            lineHeight: 1.24
            text: Almanac.verse.text
            font.pixelSize: 21 * root.u
            color: Theme.ink
        }

        Txt {
            visible: Prefs.verse && Almanac.verse.by !== ""
            text: Almanac.verse.by
            font.pixelSize: 15 * root.u
            color: Theme.muted
        }
    }

    // Lower plinth metadata below the horizon line
    Txt {
        x: 140 * root.u; y: 710 * root.u - baselineOffset
        text: "basic · niri"
        font.pixelSize: 14 * root.u; color: Theme.muted
    }
    Txt {
        x: monolith.x + 28 * root.u; y: 710 * root.u - baselineOffset
        text: Almanac.monthName.toUpperCase()
        font.pixelSize: 14 * root.u; color: Theme.muted; font.letterSpacing: 1.5
    }
}

