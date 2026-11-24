import QtQuick
import qs

// Small themable bar icons drawn in code, so they follow the theme with no image tinting.
// Placeholder geometry: swap for the brush-drawn set later without touching the bar.
// kind: signal volume battery theme power tray note wall play pause prev next list music keyboard     level: 0..1     flag: muted
Canvas {
    id: root
    property string kind: "signal"
    property real level: 1
    property bool flag: false
    property color tone: Theme.ink
    property color dim: Theme.rule
    property real px: 16                     // size of the icon in pixels (it is drawn on a 16 grid and scaled)
    width: (kind === "volume" ? 32 : 16) * px / 16; height: px
    onPxChanged: requestPaint()
    onWidthChanged: requestPaint()

    onKindChanged: requestPaint()
    onLevelChanged: requestPaint()
    onFlagChanged: requestPaint()
    onToneChanged: requestPaint()
    onDimChanged: requestPaint()
    Component.onCompleted: requestPaint()
    Connections { target: Theme; function onDarkChanged() { root.requestPaint() } }

    onPaint: {
        const c = getContext("2d");
        c.setTransform(1, 0, 0, 1, 0, 0);
        c.clearRect(0, 0, width, height);
        c.setTransform(px / 16, 0, 0, px / 16, 0, 0);
        c.fillStyle = tone; c.strokeStyle = tone;
        c.lineWidth = 1.5; c.lineJoin = "miter"; c.lineCap = "butt";
        const lv = Math.max(0, Math.min(1, level));

        if (kind === "signal") {
            const n = Math.round(lv * 4);
            for (let i = 0; i < 4; i++) {
                c.fillStyle = i < n ? tone : dim;
                const h = 3 + i * 3;
                c.fillRect(1 + i * 4, 14 - h, 3, h);
            }
        } else if (kind === "volume") {
            c.beginPath();                                   // speaker
            c.moveTo(1, 6); c.lineTo(4, 6); c.lineTo(8, 3); c.lineTo(8, 13); c.lineTo(4, 10); c.lineTo(1, 10);
            c.closePath(); c.fill();
            // level: a wedge. More sound = longer and thicker at the far end.
            const len = 3 + 19 * lv, endT = 1.5 + 6.5 * lv;
            c.fillStyle = flag ? dim : tone;                 // muted: same wedge, drawn dim
            c.beginPath();
            c.moveTo(10, 8 - 0.75); c.lineTo(10 + len, 8 - endT / 2);
            c.lineTo(10 + len, 8 + endT / 2); c.lineTo(10, 8 + 0.75);
            c.closePath(); c.fill();
        } else if (kind === "battery") {
            c.lineWidth = 1;
            c.strokeRect(1.5, 4.5, 11, 7);
            c.fillRect(13, 6.5, 2, 3);
            c.fillRect(3, 6, 8 * lv, 4);
        } else if (kind === "theme") {
            c.strokeRect(2.75, 2.75, 10.5, 10.5);
            if (Theme.dark) c.fillRect(8, 3, 5, 10); else c.fillRect(3, 3, 5, 10);
        } else if (kind === "power") {
            // open box with a straight line through the gap (a square power symbol, no arrow)
            c.beginPath(); c.moveTo(3.5, 5); c.lineTo(3.5, 13.5); c.lineTo(12.5, 13.5); c.lineTo(12.5, 5); c.stroke();
            c.beginPath(); c.moveTo(8, 1.5); c.lineTo(8, 8.5); c.stroke();
        } else if (kind === "note") {
            c.strokeRect(2.75, 2.75, 10.5, 8.5);
            c.beginPath(); c.moveTo(4.5, 11); c.lineTo(4.5, 14.5); c.lineTo(8, 11); c.stroke();
            if (flag) { c.fillStyle = Theme.red; c.fillRect(10, 0.5, 5, 5); }
        } else if (kind === "wall") {
            c.strokeRect(2.75, 2.75, 10.5, 10.5);
            c.fillRect(4.5, 8, 4, 4);
            c.fillRect(9.5, 4.5, 2.5, 2.5);
        } else if (kind === "keyboard") {
            c.lineWidth = 1.25;
            c.strokeRect(1.625, 3.625, 12.75, 8.75);
            for (let i = 0; i < 4; i++) c.fillRect(3.25 + i * 2.6, 5.25, 1.5, 1.5);
            for (let i = 0; i < 3; i++) c.fillRect(4.5 + i * 2.6, 7.5, 1.5, 1.5);
            c.fillRect(5, 9.85, 6, 1.35);
        } else if (kind === "play") {
            c.beginPath(); c.moveTo(4, 2); c.lineTo(13.5, 8); c.lineTo(4, 14); c.closePath(); c.fill();
        } else if (kind === "pause") {
            c.fillRect(3.5, 2.5, 3.2, 11); c.fillRect(9.3, 2.5, 3.2, 11);
        } else if (kind === "prev") {
            c.fillRect(2.5, 2.5, 2.2, 11);
            c.beginPath(); c.moveTo(13.5, 2.5); c.lineTo(5.5, 8); c.lineTo(13.5, 13.5); c.closePath(); c.fill();
        } else if (kind === "next") {
            c.fillRect(11.3, 2.5, 2.2, 11);
            c.beginPath(); c.moveTo(2.5, 2.5); c.lineTo(10.5, 8); c.lineTo(2.5, 13.5); c.closePath(); c.fill();
        } else if (kind === "list") {
            for (let i = 0; i < 3; i++) { c.fillRect(2, 3 + i * 4.5, 2.2, 2.2); c.fillRect(6, 3 + i * 4.5, 8, 2.2); }
        } else if (kind === "music") {
            c.fillRect(8.4, 2, 1.8, 9.5); c.fillRect(4, 9.5, 5, 4); c.fillRect(10.2, 2, 3.8, 2.4);
        } else if (kind === "tray") {
            c.strokeRect(3.75, 3.75, 8.5, 8.5);
        }
    }
}
