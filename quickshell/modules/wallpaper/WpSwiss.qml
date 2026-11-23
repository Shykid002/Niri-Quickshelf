import QtQuick
import qs
import qs.components
import qs.services

// Design 11, "Swiss": high-contrast inverted poster card (dark on Paper, light on Ink) with active cover accent.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    // Left-column metadata on desktop margin
    Column {
        x: 110 * root.u; y: 210 * root.u
        width: root.width * 0.34
        spacing: 18 * root.u

        Txt {
            text: Almanac.numeral
            font.pixelSize: 160 * root.u
            font.features: ({ "onum": 1, "pnum": 1 })
        }
        Rectangle { width: 112 * root.u; height: 1; color: Theme.ink }
        Txt {
            text: Almanac.weekday + ", " + Almanac.dateWords.replace("The ", "")
            font.pixelSize: 21 * root.u
            color: Theme.muted
        }
        Txt {
            visible: Prefs.verse
            width: parent.width
            wrapMode: Text.WordWrap
            lineHeight: 1.25
            text: Almanac.verse.text
            font.pixelSize: 19 * root.u
            color: Theme.ink
        }
    }

    // ── SWISS GRAPHIC DESIGN POSTER CARD (RIGHT) ────────────
    Item {
        id: card
        x: root.width - width - 120 * root.u
        y: 85 * root.u
        width: 520 * root.u
        height: 730 * root.u
        clip: true

        // Dark cover (#1D1C1A) in Paper mode; White cover (#E7E2D5) in Ink mode
        Rectangle { x: 0; y: 0; width: 68 * root.u; height: parent.height; color: Theme.indigo }
        Rectangle { x: 68 * root.u; y: 0; width: parent.width - 116 * root.u; height: parent.height; color: Theme.ink }
        Rectangle { anchors.right: parent.right; y: 0; width: 48 * root.u; height: parent.height; color: Theme.cover }

        // Top two-column Swiss International Style header
        Column {
            x: 96 * root.u; y: 38 * root.u
            width: 170 * root.u
            spacing: 2 * root.u
            Txt { text: Almanac.monthName; font.pixelSize: 19 * root.u; font.bold: true; color: Theme.cover }
            Txt { text: Almanac.weekday;   font.pixelSize: 19 * root.u; font.bold: true; color: Theme.cover }
            Txt { text: Almanac.roman;     font.pixelSize: 19 * root.u; font.bold: true; color: Theme.cover }
            Item { width: 1; height: 10 * root.u }
            Txt { text: "Basic · Niri";    font.pixelSize: 19 * root.u; font.bold: true; color: Theme.indigo }
            Txt { text: "Paper & Ink";     font.pixelSize: 19 * root.u; font.bold: true; color: Theme.indigo }
        }

        Column {
            x: 274 * root.u; y: 38 * root.u
            width: 185 * root.u
            spacing: 2 * root.u
            Txt {
                width: parent.width; wrapMode: Text.WordWrap; lineHeight: 1.08
                text: Almanac.coverNo + " Days of\n" + Almanac.monthName + "\nGraphic Design"
                font.pixelSize: 19 * root.u; font.bold: true; color: Theme.paper
            }
        }

        // Overlapping geometric Swiss Cross (+) & lowercase 'a' glyph
        Canvas {
            id: swissGlyph
            x: 68 * root.u
            y: 230 * root.u
            width: card.width - 116 * root.u
            height: card.height - 230 * root.u

            readonly property color cAccent: Theme.cover
            readonly property color cBlue: Theme.indigo
            readonly property color cGlyph: Theme.paper
            onCAccentChanged: requestPaint()
            onCBlueChanged: requestPaint()
            onCGlyphChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var s = width / 404.0;
                ctx.scale(s, s);

                function drawCross(cx, cy, armLen, thick, r, fill) {
                    ctx.fillStyle = fill;
                    ctx.beginPath();
                    ctx.roundedRect(cx - thick / 2, cy - armLen / 2, thick, armLen, r, r);
                    ctx.roundedRect(cx - armLen / 2, cy - thick / 2, armLen, thick, r, r);
                    ctx.fill();
                }

                // 1. Cover-colour Swiss Plus behind
                drawCross(155, 225, 290, 108, 36, cAccent);

                // 2. Bold lowercase 'a' silhouette in Indigo (offset right/down)
                ctx.fillStyle = cBlue;
                ctx.font = "bold 410px sans-serif";
                ctx.fillText("a", 136, 425);

                // 3. White 'a' on dark Paper cover / Dark 'a' on white Ink cover
                ctx.fillStyle = cGlyph;
                ctx.fillText("a", 122, 412);

                // 4. Translucent cover-colour overprint blend on the cross intersection
                ctx.globalAlpha = 0.55;
                drawCross(155, 225, 290, 108, 36, cAccent);
                ctx.globalAlpha = 1.0;
            }
        }
    }
}

