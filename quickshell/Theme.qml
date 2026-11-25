pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Single source of truth for colour and type.
// Light/dark follows the GNOME colour-scheme gsetting, which Ghostty also follows.
// Every colour in the shell must come from here. Never hardcode a hex elsewhere.
Singleton {
    id: root

    property bool dark: false
    property bool instant: false          // true = skip the theme-change transition
    property int  transitionHold: 220     // ms the "Held page" transition rests

    // ── palette ─────────────────────────────────────────────
    readonly property var light: ({
        paper:  "#EEEAE1", block:  "#E2DCCF", ink:    "#1D1C1A",
        muted:  "#8A8478", rule:   "#C8C0B1",
        sky:    "#7DCFFF", ochre:  "#CF9C42", indigo: "#2C3E60", pine:   "#486455",
        plum:   "#7D3B56", umber:  "#6B4C3B", mint:   "#A6E3A1", sakura: "#F5C2E7",
        sand:   "#E1D2B0"
    })
    readonly property var darkP: ({
        paper:  "#171619", block:  "#222023", ink:    "#E7E2D5",
        muted:  "#8F8A80", rule:   "#3A3636",
        sky:    "#7DCFFF", ochre:  "#D7AD59", indigo: "#6D84AF", pine:   "#7C9987",
        plum:   "#C47A98", umber:  "#B58E79", mint:   "#A6E3A1", sakura: "#F5C2E7",
        sand:   "#E1D2B0"
    })
    readonly property var p: dark ? darkP : light

    readonly property color paper:  p.paper
    readonly property color block:  p.block
    readonly property color ink:    p.ink
    readonly property color muted:  p.muted
    readonly property color rule:   p.rule

    // ── cover colours: loaded from assets/covers.tsv (shared with the shell scripts) ──
    property var coverMap: ({})                  // name -> { light, dark, label }
    property var coverNames: new Array()         // in file order

    function parseCovers(txt) {
        const map = ({});
        const names = new Array();
        const lines = String(txt).split("\n");
        for (let i = 0; i < lines.length; i++) {
            const l = lines[i];
            if (l.length === 0 || l.charAt(0) === "#") continue;
            const c = l.split("\t");
            if (c.length < 3) continue;
            map[c[0]] = { light: "#" + c[1], dark: "#" + c[2], label: c.length > 3 ? c[3] : c[0] };
            names.push(c[0]);
        }
        return { map: map, names: names };
    }
    function loadCovers() {
        try {
            const r = parseCovers(coversFile.text());
            coverMap = r.map;
            coverNames = r.names;
        } catch (e) {
            console.log("covers.tsv: " + e);
        }
    }
    // colour of a cover name in the current mode (unknown names, "mix" and the old "red" fall back to sky)
    function coverHex(name) {
        const c = coverMap[name];
        return c ? (dark ? c.dark : c.light) : p.sky;
    }

    FileView {
        id: coversFile
        path: Quickshell.shellDir + "/assets/covers.tsv"
        blockLoading: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.loadCovers()
    }
    Component.onCompleted: loadCovers()

    // Active cover colour chosen in Settings > Look. Follows paper / ink.
    readonly property color cover:  Prefs.cover === "mix" ? p.sky : coverHex(Prefs.cover)

    readonly property color sky:    p.sky
    readonly property color ochre:  p.ochre
    readonly property color indigo: p.indigo
    readonly property color pine:   p.pine
    readonly property color plum:   p.plum
    readonly property color umber:  p.umber
    readonly property color mint:   p.mint
    readonly property color sakura: p.sakura
    readonly property color sand:   p.sand
    readonly property color red:    cover

    // ── type ────────────────────────────────────────────────
    readonly property string serif: "EB Garamond"
    readonly property string mono:  "Monaspace Xenon"
    readonly property int    size:  15

    // ── cursor theme to use for the current mode ────────────
    readonly property string cursorTheme: "rice-" + (dark ? "ink" : "paper") + "-" + (Prefs.cursorStyle || "box") + "-" +
        (coverMap[Prefs.cover] !== undefined ? Prefs.cover : "sky")

    // ── gsetting sync ───────────────────────────────────────
    function apply(toDark) {
        dark = toDark;
        setter.exec(new Array("gsettings", "set", "org.gnome.desktop.interface", "color-scheme",
                     toDark ? "prefer-dark" : "prefer-light"));
        syncNow(toDark);
    }
    // runs rice-theme right away (rice-theme serialises itself with flock)
    function syncNow(toDark) {
        const c = String(Prefs.cover).replace(/[^a-z0-9_-]/g, "");
        const st = String(Prefs.cursorStyle || "box").replace(/[^a-z]/g, "");
        const sz = Number(Prefs.cursorSize || 24);
        Quickshell.execDetached(new Array("sh", "-c", '"$HOME/.local/bin/rice-theme" ' + (toDark ? "dark" : "light") + " " + c + " " + st + " " + sz));
    }
    // debounced: use this for cover clicks so clicking through the swatches runs rice-theme only once
    function syncApps(toDark) {
        syncTimer.targetDark = toDark;
        syncTimer.restart();
    }
    function toggle(ox, oy, screenName) {
        const nextDark = !dark;
        if (root.instant || Prefs.themeChange === "none") {
            root.apply(nextDark);
            return;
        }
        fallbackTimer.targetDark = nextDark;
        fallbackTimer.restart();
        PageTurn.start(nextDark, ox, oy, screenName);
    }

    Timer {
        id: syncTimer
        property bool targetDark: false
        interval: 250
        onTriggered: root.syncNow(targetDark)
    }
    Timer {
        id: fallbackTimer
        property bool targetDark: false
        interval: 16
        onTriggered: if (root.dark !== targetDark) root.apply(targetDark)
    }

    Process {
        command: new Array("gsettings", "get", "org.gnome.desktop.interface", "color-scheme")
        running: true
        stdout: StdioCollector { onStreamFinished: root.dark = text.indexOf("prefer-dark") >= 0 }
    }
    Process {
        command: new Array("gsettings", "monitor", "org.gnome.desktop.interface", "color-scheme")
        running: true
        stdout: SplitParser { onRead: data => root.dark = data.indexOf("prefer-dark") >= 0 }
    }
    Process { id: setter }
}
