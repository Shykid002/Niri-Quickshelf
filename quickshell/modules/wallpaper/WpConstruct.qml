import QtQuick
import qs
import qs.components
import qs.services

// Design 12, "Construct": Swiss geometric construction grid with circle, sweeping arc, and dual blocks.
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

    // ── CONSTRUCTION GRID POSTER CARD (RIGHT) ───────────────
    Item {
        id: card
        x: root.width - width - 120 * root.u
        y: 85 * root.u
        width: 520 * root.u
        height: 730 * root.u
        clip: true

        Rectangle { anchors.fill: parent; color: Theme.block }

        Canvas {
            anchors.fill: parent
            readonly property color cLine: Theme.ink
            readonly property color cPrimary: Theme.cover
            readonly property color cSecondary: Theme.pine
            onCLineChanged: requestPaint()
            onCPrimaryChanged: requestPaint()
            onCSecondaryChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const s = width / 520.0;
                ctx.scale(s, s);

                // 1. Secondary accent rectangle (top-left)
                ctx.fillStyle = cSecondary;
                ctx.fillRect(28, 38, 108, 372);

                // 2. Primary cover-colour rectangle (bottom-right)
                ctx.fillStyle = cPrimary;
                ctx.fillRect(212, 408, 280, 284);

                // 3. Fine construction lines (vertical & horizontal hairlines)
                ctx.strokeStyle = cLine;
                ctx.lineWidth = 1.1;

                function vline(vx) { ctx.beginPath(); ctx.moveTo(vx, 0); ctx.lineTo(vx, 730); ctx.stroke(); }
                function hline(hy) { ctx.beginPath(); ctx.moveTo(0, hy); ctx.lineTo(520, hy); ctx.stroke(); }

                vline(28); vline(136); vline(212); vline(377); vline(492);
                hline(38); hline(78); hline(243); hline(408); hline(656); hline(692);

                // 4. Tangent circle & sweeping quarter-arc
                ctx.beginPath();
                ctx.arc(212, 243, 165, 0, Math.PI * 2);
                ctx.stroke();

                ctx.beginPath();
                ctx.arc(492, 656, 438, Math.PI, Math.PI * 1.5);
                ctx.stroke();
            }
        }
    }
}
