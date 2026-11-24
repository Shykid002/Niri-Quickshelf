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

    // Active cover colour chosen in Settings > Look. Follows paper / ink.
    readonly property color cover:  Prefs.cover === "mix" ? p.sky : (p[Prefs.cover] || p.sky)

    readonly property color sky:    p.sky
    readonly property color ochre:  p.ochre
    readonly property color indigo: p.indigo
    readonly property color pine:   p.pine
    readonly property color plum:   p.plum
    readonly property color umber:  p.umber
    readonly property color mint:   p.mint
    readonly property color sakura: p.sakura
    readonly property color sand:   p.sand
    readonly property color red:    p.sky

    // ── type ────────────────────────────────────────────────
    readonly property string serif: "EB Garamond"
    readonly property string mono:  "Monaspace Xenon"
    readonly property int    size:  15

    // ── cursor theme to use for the current mode ────────────
    readonly property string cursorTheme: "rice-" + (dark ? "ink" : "paper") + "-" +
        (new Array("indigo", "ochre", "pine", "plum", "umber", "mint", "sakura", "sand").indexOf(Prefs.cover) >= 0 ? Prefs.cover : "sky")

    // ── gsetting sync ───────────────────────────────────────
    function apply(toDark) {
        dark = toDark;
        setter.exec(new Array("gsettings", "set", "org.gnome.desktop.interface", "color-scheme",
                     toDark ? "prefer-dark" : "prefer-light"));
        syncApps(toDark);
    }
    function syncApps(toDark) {
        Quickshell.execDetached(new Array("sh", "-c", '"$HOME/.local/bin/rice-theme" ' + (toDark ? "dark" : "light") + " " + Prefs.cover));
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
