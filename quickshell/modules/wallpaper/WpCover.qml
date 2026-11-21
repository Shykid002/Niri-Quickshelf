import QtQuick
import qs
import qs.components
import qs.services

// Design 1, "Cover": the book cover for the day. Layout measured from the reference frames
// (units u = height / 900).
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    // crop marks
    CropMark { corner: "tl"; x: 61 * root.u; y: 89 * root.u; arm: 21 * root.u }
    CropMark { corner: "br"; x: root.width - 61 * root.u - width; y: root.height - 61 * root.u - height; arm: 21 * root.u }

    // big day numeral (old-style figures, which is why the 1 reads like a small capital I)
    Txt {
        x: 164 * root.u
        y: 312 * root.u - baselineOffset
        text: Almanac.numeral
        font.pixelSize: 160 * root.u
        font.features: ({ "onum": 1, "pnum": 1 })
    }

    Txt {   // weekday
        x: 335 * root.u
        y: 237 * root.u - baselineOffset
        text: Almanac.weekday
        font.pixelSize: 52 * root.u
    }
    Txt {   // date in words
        x: 335 * root.u
        y: 280 * root.u - baselineOffset
        text: Almanac.dateWords
        font.pixelSize: 19 * root.u
        color: Theme.muted
    }
    Rectangle {   // short rule
        x: 335 * root.u; y: 317 * root.u
        width: 112 * root.u; height: 1; color: Theme.ink
    }
    Txt {   // Roman year
        x: 335 * root.u
        y: 362 * root.u - baselineOffset
        text: Almanac.roman
        font.pixelSize: 20 * root.u
        font.letterSpacing: 0.5
    }
    Txt {   // verse
        x: 335 * root.u
        y: 452 * root.u - baselineOffset
        visible: Prefs.verse
        text: Almanac.verse.text
        font.pixelSize: 21 * root.u
    }
    Txt {   // author
        x: 335 * root.u
        y: 491 * root.u - baselineOffset
        visible: Prefs.verse
        text: Almanac.verse.by
        font.pixelSize: 16 * root.u
        color: Theme.muted
    }

    // colour block, numbered with the day of the year
    Rectangle {
        id: cover
        x: root.width - 134 * root.u - width
        y: 389 * root.u
        width: 443 * root.u; height: 390 * root.u
        color: Prefs.cover === "mix" ? "transparent" : Theme.cover

        Grid {   // "mix": four-colour cover
            visible: Prefs.cover === "mix"
            anchors.fill: parent; columns: 2
            Repeater {
                model: [Theme.indigo, Theme.red, Theme.pine, Theme.ochre]
                delegate: Rectangle { required property var modelData; width: cover.width / 2; height: cover.height / 2; color: modelData }
            }
        }
        Txt {
            x: 21 * root.u
            y: 364 * root.u - baselineOffset
            text: Almanac.coverNo
            font.pixelSize: 16 * root.u
            color: Theme.paper
        }
    }
    Rectangle {   // small square overlapping the block's top-left corner
        x: cover.x - 21 * root.u; y: cover.y - 21 * root.u
        width: 42 * root.u; height: 42 * root.u
        color: Theme.ink
    }

    Txt {   // caption
        x: 147 * root.u
        y: 775 * root.u - baselineOffset
        text: "basic · niri"
        font.pixelSize: 14 * root.u
        color: Theme.muted
    }
}
