pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs

// Notification daemon (org.freedesktop.Notifications) + the list everything else shows.
// Needs: no other daemon running (mako, dunst, swaync...). Test: notify-send "Hello" "World"
// New notifications are kept until you clear them. There are no toast windows: the bar item
// reveals the latest one for a few seconds instead (unless Quiet is on).
Singleton {
    id: root
    function start() {}                                   // referencing this singleton creates it

    readonly property var list: server.trackedNotifications.values          // oldest first
    readonly property var newest: list.slice().reverse()                    // newest first
    readonly property int count: list.length
    readonly property var latest: list.length > 0 ? list[list.length - 1] : null
    property string owner: ""                 // program that owns org.freedesktop.Notifications ("qs" = us)
    readonly property bool conflict: owner !== "" && owner !== "qs"
    property bool flash: false                                              // a new one just arrived

    function clearAll() { for (const n of list.slice()) n.dismiss() }
    function strip(s) { return (s || "").replace(/<[^>]*>/g, "") }          // bodies may carry HTML

    property var stamps: ({})                  // notification id -> arrival time (ms)
    function timeText(n) { const t = stamps[n.id]; return t ? Qt.formatTime(new Date(t), "HH:mm") : "" }
    // Each notification's own little box: red when critical, otherwise one palette colour per app (stable).
    function colorOf(n) {
        if (n.urgency === NotificationUrgency.Critical) return Theme.red;
        const a = n.appName || ""; let h = 0;
        for (let i = 0; i < a.length; i++) h = (h * 31 + a.charCodeAt(i)) % 997;
        return [Theme.indigo, Theme.ochre, Theme.pine, Theme.cover][h % 4];
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: false
        imageSupported: false
        onNotification: n => {
            console.log("rice: notification from", n.appName, "-", n.summary);
            n.tracked = true;
            const st = Object.assign({}, root.stamps); st[n.id] = Date.now(); root.stamps = st;   // arrival time
            if (!Prefs.quiet) { root.flash = true; flashTimer.restart(); }
            if (!soundGate.running) { Sounds.play("notify"); soundGate.start() }        // Sounds.play already respects Quiet
        }
    }
    Process {
        id: ownerProc
        command: ["sh", "-c", "busctl --user list 2>/dev/null | awk '$1==\"org.freedesktop.Notifications\"{print $3}'"]
        stdout: StdioCollector { onStreamFinished: root.owner = text.trim() }
    }
    Timer { interval: 15000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: { if (!ownerProc.running) ownerProc.running = true } }
    Timer { id: soundGate; interval: 1000 }                                   // a burst of notifications rings once
    Timer { id: flashTimer; interval: 6000; onTriggered: root.flash = false }
}
