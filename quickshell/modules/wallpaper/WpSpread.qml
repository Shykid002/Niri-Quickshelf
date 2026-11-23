import QtQuick
import qs
import qs.components
import qs.services

// Design 8, "Spread": an open two-page book layout with a central binding crease and running headers.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    // Outer folio frame
    Rectangle {
        x: 72 * root.u; y: 64 * root.u
        width: root.width - 144 * root.u; height: root.height - 128 * root.u
        color: "transparent"
        border { width: 1; color: Theme.rule }
    }

    // Central book gutter / spine crease
    Rectangle {
        x: root.width / 2; y: 64 * root.u
        width: 1; height: root.height - 128 * root.u
        color: Theme.rule
    }
    Rectangle {
        x: root.width / 2 - 12 * root.u; y: 64 * root.u
        width: 24 * root.u; height: root.height - 128 * root.u
        color: Theme.block
        opacity: 0.35
    }

    // ── VERSO (LEFT PAGE) ───────────────────────────────────
    Txt {
        x: 112 * root.u; y: 108 * root.u - baselineOffset
        text: Almanac.roman
        font.pixelSize: 13 * root.u; color: Theme.muted; font.letterSpacing: 1.5
    }
    Txt {
        x: root.width / 2 - width - 44 * root.u; y: 108 * root.u - baselineOffset
        text: Almanac.monthName.toUpperCase()
        font.pixelSize: 13 * root.u; color: Theme.muted; font.letterSpacing: 1.5
    }
    Rectangle {
        x: 112 * root.u; y: 124 * root.u
        width: root.width / 2 - 156 * root.u; height: 1; color: Theme.rule
    }

    // Large chapter numeral & date on Verso
    Txt {
        x: 112 * root.u; y: 340 * root.u - baselineOffset
        text: Almanac.numeral
        font.pixelSize: 185 * root.u
        font.features: ({ "onum": 1, "pnum": 1 })
    }
    Rectangle {
        x: 116 * root.u; y: 382 * root.u
        width: 54 * root.u; height: 6 * root.u; color: Theme.cover
    }
    Txt {
        x: 112 * root.u; y: 446 * root.u - baselineOffset
        text: Almanac.weekday
        font.pixelSize: 44 * root.u
    }
    Txt {
        x: 112 * root.u; y: 486 * root.u - baselineOffset
        text: Almanac.dateWords
        font.pixelSize: 19 * root.u; color: Theme.muted
    }

    // Verso folio page number
    Txt {
        x: 112 * root.u; y: root.height - 92 * root.u - baselineOffset
        text: Almanac.coverNo
        font.pixelSize: 14 * root.u; color: Theme.muted
    }

    // ── RECTO (RIGHT PAGE) ──────────────────────────────────
    Txt {
        x: root.width / 2 + 44 * root.u; y: 108 * root.u - baselineOffset
        text: "COMMONPLACE BOOK"
        font.pixelSize: 13 * root.u; color: Theme.muted; font.letterSpacing: 1.5
    }
    Txt {
        x: root.width - 112 * root.u - width; y: 108 * root.u - baselineOffset
        text: Theme.dark ? "INK EDITION" : "PAPER EDITION"
        font.pixelSize: 13 * root.u; color: Theme.cover; font.letterSpacing: 1.5
    }
    Rectangle {
        x: root.width / 2 + 44 * root.u; y: 124 * root.u
        width: root.width / 2 - 156 * root.u; height: 1; color: Theme.rule
    }

    // Literary passage or architectural block on Recto
    Column {
        x: root.width / 2 + 44 * root.u
        y: 230 * root.u
        width: root.width / 2 - 168 * root.u
        spacing: 24 * root.u

        Rectangle { width: 32 * root.u; height: 32 * root.u; color: Theme.cover }

        Txt {
            width: parent.width
            wrapMode: Text.WordWrap
            lineHeight: 1.28
            text: Prefs.verse ? Almanac.verse.text : Almanac.weekday + ", " + Almanac.dateWords.replace("The ", "")
            font.pixelSize: 30 * root.u
        }

        Rectangle { width: 84 * root.u; height: 1; color: Theme.ink }

        Txt {
            visible: Prefs.verse && Almanac.verse.by !== ""
            text: "— " + Almanac.verse.by
            font.pixelSize: 18 * root.u
            color: Theme.muted
        }
    }

    // Recto colophon & folio number
    Txt {
        x: root.width / 2 + 44 * root.u; y: root.height - 92 * root.u - baselineOffset
        text: "basic · niri"
        font.pixelSize: 14 * root.u; color: Theme.muted
    }
    Txt {
        x: root.width - 112 * root.u - width; y: root.height - 92 * root.u - baselineOffset
        text: Almanac.roman
        font.pixelSize: 14 * root.u; color: Theme.muted
    }
}

