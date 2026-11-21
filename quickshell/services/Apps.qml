pragma Singleton
import QtQuick
import Quickshell
import qs

// Launcher search over installed .desktop applications.
Singleton {
    readonly property var all: DesktopEntries.applications.values
        .filter(e => !e.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    function search(q) {
        if (!q) return all.slice(0, 6);
        const scored = [];
        for (const e of all) {
            const n = e.name.toLowerCase();
            let s = -1;
            if (n.indexOf(q) === 0) s = 0;
            else if (n.indexOf(" " + q) >= 0) s = 1;
            else if (n.indexOf(q) >= 0) s = 2;
            else if (((e.genericName || "") + " " + (e.keywords || []).join(" ")).toLowerCase().indexOf(q) >= 0) s = 3;
            if (s >= 0) scored.push({ e: e, s: s });
        }
        scored.sort((a, b) => a.s - b.s || a.e.name.localeCompare(b.e.name));
        return scored.slice(0, 8).map(x => x.e);
    }

    function esc(s) { return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;") }
    // matched part in vermilion, as in the "Ghos|tty" frame
    function highlight(name, q) {
        const i = q ? name.toLowerCase().indexOf(q) : -1;
        if (i < 0) return esc(name);
        return esc(name.slice(0, i)) + '<font color="' + Theme.cover + '">' + esc(name.slice(i, i + q.length)) + '</font>'
             + esc(name.slice(i + q.length));
    }
}
