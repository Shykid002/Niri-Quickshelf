pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// The music window's spectrum. Real data from `cava` (sudo pacman -S cava) while the window is open and
// music is playing; a gentle simulated spectrum when cava is not installed. Peaks fall slowly.
Singleton {
    id: root
    readonly property int count: 40
    property var bars: []
    property var peaks: []
    property bool hasCava: false
    readonly property bool wanted: Music.open && Music.playing

    function push(a) {
        const b = [], pk = [];
        for (let i = 0; i < count; i++) {
            const v = Math.max(0, Math.min(100, a[i] || 0));
            b.push(v); pk.push(Math.max(v, (peaks[i] || 0) - 1.6));
        }
        bars = b; peaks = pk;
    }
    Component.onCompleted: push([])

    Process {
        command: ["sh", "-c", "command -v cava"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.hasCava = text.trim() !== "" }
    }
    Process {
        command: ["cava", "-p", Quickshell.shellDir + "/assets/cava.conf"]
        running: root.hasCava && root.wanted                     // starts and stops with the window and the music
        stdout: SplitParser {
            onRead: data => {
                const a = [];
                for (const x of data.split(";")) if (x !== "") a.push(parseInt(x));
                if (a.length > 0) root.push(a);
            }
        }
    }

    property real t: 0
    Timer {   // no cava: a calm made-up spectrum so the window still moves with the music
        interval: 50; repeat: true; running: !root.hasCava && root.wanted
        onTriggered: {
            root.t += 0.12;
            const a = [];
            for (let i = 0; i < root.count; i++)
                a.push(24 + 46 * Math.abs(Math.sin(root.t * 1.3 + i * 0.55)) * (1 - 0.5 * i / root.count) + 14 * Math.sin(root.t * 2.1 + i * 1.7));
            root.push(a);
        }
    }
    Timer {   // when the music stops, let the bars sink
        interval: 60; repeat: true
        running: !root.wanted && root.bars.some(v => v > 0.5)
        onTriggered: root.push(root.bars.map(v => v * 0.8))
    }
}
