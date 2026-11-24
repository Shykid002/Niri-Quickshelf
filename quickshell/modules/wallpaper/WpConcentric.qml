import QtQuick
import qs
import qs.components
import qs.services

// Design 15, "Concentric": cover-coloured concentric arc composition inspired by Tonhalle concert posters.
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

    // ── CONCENTRIC ARCS POSTER CARD (RIGHT) ─────────────────
    Item {
        id: card
        x: root.width - width - 120 * root.u
        y: 85 * root.u
        width: 520 * root.u
        height: 730 * root.u
        clip: true

        Canvas {
            anchors.fill: parent
            readonly property color cField: Theme.cover
            readonly property color cBand: Theme.block
            readonly property color cDark: Theme.ink
            onCFieldChanged: requestPaint()
            onCBandChanged: requestPaint()
            onCDarkChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const s = width / 520.0;
                ctx.scale(s, s);

                // Solid active cover-colour poster field
                ctx.fillStyle = cField;
                ctx.fillRect(0, 0, 520, 730);

                const cx = 128;
                const cy = 428;

                // Broad warm paper/block sector ring
                ctx.fillStyle = cBand;
                ctx.beginPath();
                ctx.arc(cx, cy, 302, -Math.PI * 0.56, Math.PI * 0.62, false);
                ctx.lineTo(cx, cy);
                ctx.closePath();
                ctx.fill();

                // Concentric ink & cover-colour arc bands
                function drawArcBand(rInner, rOuter, a0, a1, col) {
                    ctx.fillStyle = col;
                    ctx.beginPath();
                    ctx.arc(cx, cy, rOuter, a0, a1, false);
                    ctx.arc(cx, cy, rInner, a1, a0, true);
                    ctx.closePath();
                    ctx.fill();
                }

                drawArcBand(152, 194, -Math.PI * 0.50, Math.PI * 0.34, cDark);
                drawArcBand(118, 134, -Math.PI * 0.24, Math.PI * 0.26, cField);
                drawArcBand(94,  104, -Math.PI * 0.14, Math.PI * 0.19, cDark);

                // Fine concentric hairline arcs
                ctx.strokeStyle = cBand;
                ctx.lineWidth = 1.2;
                function hairArc(r) {
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, -Math.PI * 0.55, Math.PI * 0.65, false);
                    ctx.stroke();
                }
                hairArc(218); hairArc(242); hairArc(268); hairArc(325);
            }
        }
    }
}

