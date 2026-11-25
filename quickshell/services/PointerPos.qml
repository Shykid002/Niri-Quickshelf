pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property real x: 960
    property real y: 540
    property real maxW: 1920
    property real maxH: 1080
    signal moved(real nx, real ny, real dx, real dy)

    function syncExact(ex, ey) {
        const dx = ex - x;
        const dy = ey - y;
        x = Math.max(0, Math.min(maxW - 1, ex));
        y = Math.max(0, Math.min(maxH - 1, ey));
        if (Math.hypot(dx, dy) > 0.2) moved(x, y, dx, dy);
    }

    function addDelta(dx, dy) {
        const nx = Math.max(0, Math.min(maxW - 1, x + dx));
        const ny = Math.max(0, Math.min(maxH - 1, y + dy));
        const rdx = nx - x;
        const rdy = ny - y;
        x = nx;
        y = ny;
        if (Math.hypot(rdx, rdy) > 0.2) moved(x, y, rdx, rdy);
    }
}
