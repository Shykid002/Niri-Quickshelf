import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        readonly property string trailMode: Prefs.cursorTrail || "off"
        readonly property bool trailOn: trailMode !== "off"
        readonly property bool ringOn: !!Prefs.musicRing && (typeof Player !== "undefined" ? Player.playing : true)
        readonly property bool activeFx: trailOn || ringOn

        visible: activeFx
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors { top: true; bottom: true; left: true; right: true }

        // Starts uncalibrated so the first mouse move captures exact wl_pointer coords from Niri,
        // then shrinks to a tiny 2px hollow square at screen center for periodic recalibration + full click passthrough!
        property bool calibrated: false
        onActiveFxChanged: if (activeFx) calibrated = false

        mask: calibrated ? calRingRegion : fullRegion
        Region { id: fullRegion }
        Region {
            id: calRingRegion
            // 2px hollow square around screen center (~1500 px², <0.1% of screen) for silent drift correction
            Region { x: Math.round(win.width / 2 - 120); y: Math.round(win.height / 2 - 120); width: 240; height: 2 }
            Region { x: Math.round(win.width / 2 - 120); y: Math.round(win.height / 2 + 118); width: 240; height: 2 }
            Region { x: Math.round(win.width / 2 - 120); y: Math.round(win.height / 2 - 118); width: 2;   height: 236 }
            Region { x: Math.round(win.width / 2 + 118); y: Math.round(win.height / 2 - 118); width: 2;   height: 236 }
        }

        // Captures exact Niri wl_pointer position on initial move and whenever crossing the 2px calibration ring
        HoverHandler {
            onPointChanged: {
                PointerPos.syncExact(point.position.x, point.position.y);
                if (!win.calibrated) win.calibrated = true;
            }
        }

        onWidthChanged: if (width > 0) PointerPos.maxW = width
        onHeightChanged: if (height > 0) PointerPos.maxH = height

        property real phase: 0.0
        property var points: new Array()
        property var sparks: new Array()

        readonly property real centerOffX: (Prefs.cursorStyle === "ring") ? 0 : (Prefs.cursorSize || 24) * 0.34
        readonly property real centerOffY: (Prefs.cursorStyle === "ring") ? 0 : (Prefs.cursorSize || 24) * 0.34

        Process {
            id: watcher
            running: win.activeFx
            command: new Array(Quickshell.env("HOME") + "/.local/bin/rice-pointer-watch")
            stdout: SplitParser {
                onRead: line => {
                    const str = String(line).trim();
                    const sep = str.indexOf(" ");
                    if (sep <= 0) return;
                    const dx = Number(str.slice(0, sep));
                    const dy = Number(str.slice(sep + 1));
                    if (!isNaN(dx) && !isNaN(dy)) PointerPos.addDelta(dx, dy);
                }
            }
        }

        Connections {
            target: PointerPos
            function onMoved(nx, ny, dx, dy) {
                if (!win.activeFx) return;
                const dist = Math.hypot(dx, dy);
                if (dist < 0.5) return;

                const ux = dx / dist;
                const uy = dy / dist;
                const tailX = nx + win.centerOffX - ux * 5.0;
                const tailY = ny + win.centerOffY - uy * 5.0;

                if (win.trailMode === "comet") {
                    win.points.push({ x: tailX, y: tailY, life: 1.0 });
                    if (win.points.length > 22) win.points.shift();
                } else if (win.trailMode === "sparks") {
                    const count = Math.min(4, Math.max(1, Math.floor(dist / 8)));
                    for (let i = 0; i < count; i++) {
                        const spread = (Math.random() - 0.5) * 1.1;
                        const baseAng = Math.atan2(-uy, -ux) + spread;
                        const spd = 0.6 + Math.random() * 1.8;
                        win.sparks.push({
                            x: tailX + (Math.random() - 0.5) * 4,
                            y: tailY + (Math.random() - 0.5) * 4,
                            vx: Math.cos(baseAng) * spd,
                            vy: Math.sin(baseAng) * spd,
                            size: 2.5 + Math.random() * 3.5,
                            life: 1.0,
                            accent: Math.random() > 0.3
                        });
                    }
                    if (win.sparks.length > 60) win.sparks.splice(0, win.sparks.length - 60);
                }
            }
        }

        Timer {
            interval: 16
            running: win.activeFx
            repeat: true
            onTriggered: {
                win.phase += 0.045;

                let alivePts = new Array();
                for (let i = 0; i < win.points.length; i++) {
                    let pt = win.points[i];
                    pt.life -= 0.085;
                    if (pt.life > 0.02) alivePts.push(pt);
                }
                win.points = alivePts;

                let aliveSpk = new Array();
                for (let i = 0; i < win.sparks.length; i++) {
                    let s = win.sparks[i];
                    s.x += s.vx;
                    s.y += s.vy;
                    s.vx *= 0.92;
                    s.vy *= 0.92;
                    s.life -= 0.055;
                    if (s.life > 0.02) aliveSpk.push(s);
                }
                win.sparks = aliveSpk;

                fxCanvas.requestPaint();
            }
        }

        Canvas {
            id: fxCanvas
            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                const cov = Theme.cover;
                const ink = Theme.ink;

                // 1. Comet tailing directly behind the pointer
                if (win.trailMode === "comet" && win.points.length > 1) {
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";
                    for (let i = 1; i < win.points.length; i++) {
                        const p0 = win.points[i - 1];
                        const p1 = win.points[i];
                        const ratio = i / win.points.length;
                        ctx.globalAlpha = Math.max(0, p1.life * ratio * 0.85);
                        ctx.strokeStyle = cov;
                        ctx.lineWidth = Math.max(1.2, ratio * (Prefs.cursorSize * 0.36));
                        ctx.beginPath();
                        ctx.moveTo(p0.x, p0.y);
                        ctx.lineTo(p1.x, p1.y);
                        ctx.stroke();
                    }
                }

                // 2. Sparks tailing behind the pointer's wake
                if (win.trailMode === "sparks" && win.sparks.length > 0) {
                    for (let i = 0; i < win.sparks.length; i++) {
                        const s = win.sparks[i];
                        ctx.globalAlpha = Math.max(0, s.life * 0.9);
                        ctx.fillStyle = s.accent ? cov : ink;
                        const sz = s.size * s.life;
                        ctx.save();
                        ctx.translate(s.x, s.y);
                        ctx.rotate((1.0 - s.life) * 1.4);
                        ctx.fillRect(-sz / 2, -sz / 2, sz, sz);
                        ctx.restore();
                    }
                }

                // 3. Audio-Reactive Music Spectrum Ring circling the pointer
                if (win.ringOn) {
                    const cx = PointerPos.x + win.centerOffX;
                    const cy = PointerPos.y + win.centerOffY;
                    const baseR = Math.max(18, (Prefs.cursorSize || 24) * 0.92);
                    const bars = (typeof Viz !== "undefined" && Viz.bars && Viz.bars.length > 0) ? Viz.bars : null;
                    const count = 28;

                    ctx.globalAlpha = 0.35;
                    ctx.strokeStyle = ink;
                    ctx.lineWidth = 1.1;
                    ctx.beginPath();
                    ctx.arc(cx, cy, baseR, 0, Math.PI * 2);
                    ctx.stroke();

                    ctx.lineCap = "round";
                    ctx.lineWidth = 2.0;
                    for (let i = 0; i < count; i++) {
                        let amp = 0.18;
                        if (bars) {
                            const idx = Math.min(bars.length - 1, Math.floor((i / count) * bars.length));
                            const val = bars[idx];
                            amp = Math.max(0.08, Math.min(1.0, Number(val || 0)));
                        } else {
                            amp = 0.22 + 0.62 * Math.abs(Math.sin(win.phase * 2.2 + i * 0.52));
                        }

                        const ang = (i / count) * Math.PI * 2 + win.phase * 0.35;
                        const len = 2.5 + amp * 13.0;
                        const r0 = baseR + 1.5;
                        const r1 = r0 + len;

                        ctx.globalAlpha = 0.50 + amp * 0.50;
                        ctx.strokeStyle = (i % 4 === 0) ? ink : cov;
                        ctx.beginPath();
                        ctx.moveTo(cx + Math.cos(ang) * r0, cy + Math.sin(ang) * r0);
ctx.lineTo(cx + Math.cos(ang) * r1, cy + Math.sin(ang) * r1);
ctx.stroke();
}
}
ctx.globalAlpha = 1.0;
}
}
}
}
