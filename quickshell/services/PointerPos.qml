pragma Singleton
import QtQuick
import Quickshell

// Estimated pointer position in GLOBAL logical coordinates (all screens together, like niri's layout).
// addDelta() is fed raw motion from bin/rice-pointer-watch; syncExact() is fed exact positions whenever the
// pointer crosses a calibration strip in CursorFxLayer. Raw motion is before niri's pointer acceleration,
// so every two exact positions teach this singleton how much to scale the raw motion (gainX / gainY).
Singleton {
    id: root
    property real x: 960
    property real y: 540
    // kept so code that still sets them does not break; the screen rectangles now come from Quickshell.screens
    property real maxW: 1920
    property real maxH: 1080

    property real gainX: 1.0
    property real gainY: 1.0
    property bool synced: false           // true once an exact position has been seen

    property real _rawX: 0                // raw motion since the last exact position
    property real _rawY: 0
    property real _syncX: 0
    property real _syncY: 0
    property bool _clamped: false         // the estimate hit a screen edge since the last exact position

    signal moved(real nx, real ny, real dx, real dy)
    signal jumped(real dist)              // a correction moved the estimate noticeably: trails should restart

    Component.onCompleted: {
        const s = Quickshell.screens;
        if (s && s.length > 0) { x = s[0].x + s[0].width / 2; y = s[0].y + s[0].height / 2; }
    }

    // nearest point inside any screen
    function clampPoint(px, py) {
        const sc = Quickshell.screens;
        if (!sc || sc.length === 0) return { x: px, y: py, clamped: false };
        let bx = px, by = py, bd = 1e18;
        for (let i = 0; i < sc.length; i++) {
            const s = sc[i];
            const cx = Math.max(s.x, Math.min(s.x + s.width - 1, px));
            const cy = Math.max(s.y, Math.min(s.y + s.height - 1, py));
            const d = (cx - px) * (cx - px) + (cy - py) * (cy - py);
            if (d < bd) { bd = d; bx = cx; by = cy; if (d === 0) break; }
        }
        return { x: bx, y: by, clamped: bd > 0 };
    }

    function blend(g, ratio) {
        const r = Math.max(0.25, Math.min(6.0, ratio));
        return g * 0.65 + r * 0.35;
    }

    // ex, ey: exact position in global logical coordinates
    function syncExact(ex, ey) {
        if (synced && !_clamped) {
            const realX = ex - _syncX, realY = ey - _syncY;
            if (Math.abs(_rawX) > 120 && Math.abs(realX) > 60 && _rawX * realX > 0) gainX = blend(gainX, realX / _rawX);
            if (Math.abs(_rawY) > 120 && Math.abs(realY) > 60 && _rawY * realY > 0) gainY = blend(gainY, realY / _rawY);
        }
        const dist = Math.hypot(ex - x, ey - y);
        const c = clampPoint(ex, ey);
        x = c.x; y = c.y;
        _syncX = x; _syncY = y; _rawX = 0; _rawY = 0; _clamped = false; synced = true;
        if (dist > 40) jumped(dist);
    }

    function addDelta(dx, dy) {
        _rawX += dx; _rawY += dy;
        const c = clampPoint(x + dx * gainX, y + dy * gainY);
        if (c.clamped) _clamped = true;
        const rdx = c.x - x, rdy = c.y - y;
        x = c.x; y = c.y;
        if (Math.hypot(rdx, rdy) > 0.2) moved(x, y, rdx, rdy);
    }
}
