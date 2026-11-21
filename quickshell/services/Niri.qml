pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// niri state via `niri msg --json`. Does nothing (quietly) when niri isn't running,
// so the bar still loads on other compositors.
Singleton {
    id: root

    readonly property bool available: !!Quickshell.env("NIRI_SOCKET")

    // [{ idx, focused, occupied }] for the focused monitor, in order
    property var    workspaces: []
    property int    focusedIndex: 0
    property string focusedOutput: ""
    property bool   focusedFloating: false
    // The active window of the focused workspace. Unlike "focused-window" it still works while the
    // drawer holds the keyboard, which is when the window-mode tiles are used.
    property var    activeId: null
    property var    windowsList: []
    property var    winModes: ({})                // tabbed / full / max, remembered per window (niri does not report them)
    readonly property bool activeFloating: { const w = windowsList.find(x => x.id === activeId); return !!w && !!w.is_floating }
    readonly property string activeMode: activeFloating ? "float" : (winModes[activeId] || "scroll")
    property var    layouts: []                   // xkb layout names, e.g. ["English (US)", "Russian"]
    property int    layoutIndex: 0
    readonly property string layoutName: {
        if (layouts.length === 0) return "";
        const n = layouts[layoutIndex] || layouts[0];
        const m = n.match(/\(([^)]+)\)/);       // "English (US)" -> "US"
        return m ? m[1] : n.slice(0, 3).toUpperCase();
    }
    property string focusedApp: ""        // "Ghostty"
    property string focusedTitle: ""      // "~/P/rice"

    function refresh() {
        if (!available) return;
        if (!wsProc.running) wsProc.running = true;
        if (!fwProc.running) fwProc.running = true;
        if (!kbProc.running) kbProc.running = true;
        if (!winsProc.running) winsProc.running = true;
    }
    function act(args) {
        if (available) Quickshell.execDetached(["niri", "msg", "action"].concat(args));
    }
    function switchLayout()      { act(["switch-layout", "next"]) }
    // Close whatever is open first, then start niri's own screenshot UI (select a region, screen or window).
    function screenshotSoon()    { shotTimer.restart() }
    // scroll = tiled, normal column | tabbed | float | full = fullscreen | max = maximised column.
    // Clicking the mode you are already in leaves it again (tabbed, float, full and max all toggle).
    function windowMode(m) {
        if (!available) return;
        const n = "niri msg action ";
        const cur = activeMode;
        const modes = Object.assign({}, winModes);
        let cmd = "";
        if (m === "float") {
            cmd = cur === "float" ? n + "move-window-to-tiling" : n + "move-window-to-floating";
            delete modes[activeId];
        } else if (m === "tabbed") {
            if (cur === "tabbed") { cmd = n + "set-column-display normal"; delete modes[activeId]; }
            else { cmd = n + "move-window-to-tiling; " + n + "set-column-display tabbed"; modes[activeId] = "tabbed"; }
        } else if (m === "full") {
            cmd = n + "fullscreen-window";
            if (cur === "full") delete modes[activeId]; else modes[activeId] = "full";
        } else if (m === "max") {
            cmd = n + "maximize-column";
            if (cur === "max") delete modes[activeId]; else modes[activeId] = "max";
        } else {
            cmd = n + "move-window-to-tiling; " + n + "set-column-display normal";
            delete modes[activeId];
        }
        winModes = modes;
        Quickshell.execDetached(["sh", "-c", cmd]);
        refreshSoon.restart();
    }
    function toggleOverview()    { act(["toggle-overview"]) }
    function focusWorkspace(idx) { act(["focus-workspace", String(idx)]) }

    function prettyApp(id) {
        const s = (id || "").split(".").pop();
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    Process {
        id: wsProc
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const all = JSON.parse(text);
                    const f = all.find(w => w.is_focused);
                    const out = f ? f.output : null;
                    root.workspaces = all.filter(w => w.output === out)
                        .sort((a, b) => a.idx - b.idx)
                        .map(w => ({ idx: w.idx, focused: w.is_focused,
                                     occupied: w.active_window_id !== null && w.active_window_id !== undefined }));
                    root.focusedIndex = f ? f.idx : 0;
                    root.focusedOutput = out || "";
                    root.activeId = (f && f.active_window_id !== undefined) ? f.active_window_id : null;
                } catch (e) {}
            }
        }
    }
    Process {
        id: kbProc
        command: ["niri", "msg", "--json", "keyboard-layouts"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const k = JSON.parse(text);
                    root.layouts = k.names || [];
                    root.layoutIndex = k.current_idx || 0;
                } catch (e) {}
            }
        }
    }
    Timer { id: shotTimer; interval: 450; onTriggered: root.act(["screenshot"]) }
    Process {
        id: winsProc
        command: ["niri", "msg", "--json", "windows"]
        stdout: StdioCollector { onStreamFinished: { try { root.windowsList = JSON.parse(text) } catch (e) {} } }
    }
    Timer { id: refreshSoon; interval: 250; onTriggered: root.refresh() }
    Process {
        id: fwProc
        command: ["niri", "msg", "--json", "focused-window"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const w = JSON.parse(text);
                    root.focusedApp = w ? root.prettyApp(w.app_id) : "";
                    root.focusedTitle = w && w.title ? w.title : "";
                    root.focusedFloating = !!(w && w.is_floating);
                } catch (e) {}
            }
        }
    }

    // Any niri event -> re-query (debounced). Simple and robust.
    Process {
        id: events
        command: ["niri", "msg", "--json", "event-stream"]
        running: root.available
        stdout: SplitParser { onRead: debounce.restart() }
        onRunningChanged: if (!running && root.available) retry.start()
    }
    Timer { id: debounce; interval: 40;   onTriggered: root.refresh() }
    Timer { id: retry;    interval: 1500; onTriggered: events.running = true }

    Component.onCompleted: refresh()
}
