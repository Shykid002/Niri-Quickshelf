pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Single source of truth for colour and type.
// Light/dark follows the GNOME colour-scheme gsetting, which Ghostty also follows.
// Every colour in the shell must come from here. Never hardcode a hex elsewhere.
//
// Hex values were sampled from the reference frames. Where the frames and the
// niri config disagreed, the niri config value was used.
Singleton {
    id: root

    property bool dark: false
    property bool instant: false          // true = skip the theme-change transition
    property int  transitionHold: 220     // ms the "Held page" transition rests

    // ── palette ─────────────────────────────────────────────
    // paper : ground          block : secondary fill (off tiles, overview)
    // ink   : text / strokes  muted : secondary text   rule : hairlines
    // red / ochre / indigo / pine : accents
    readonly property var light: ({
        paper:  "#EEEAE1", block:  "#E2DCCF", ink:    "#1D1C1A",
        muted:  "#8A8478", rule:   "#C8C0B1",
        red:    "#CA4C29", ochre:  "#CF9C42", indigo: "#2C3E60", pine:   "#486455"
    })
    readonly property var darkP: ({
        paper:  "#171619", block:  "#222023", ink:    "#E7E2D5",
        muted:  "#8F8A80", rule:   "#3A3636",
        red:    "#DE603B", ochre:  "#D7AD59", indigo: "#6D84AF", pine:   "#7C9987"
    })
    readonly property var p: dark ? darkP : light

    readonly property color paper:  p.paper
    readonly property color block:  p.block
    readonly property color ink:    p.ink
    readonly property color muted:  p.muted
    readonly property color rule:   p.rule
    readonly property color red:    p.red
    // The cover colour chosen in Settings > Look. Follows paper / ink. "mix" has no single colour,
    // so everything except the wallpaper block uses red for it.
    readonly property color cover: Prefs.cover === "mix" ? p.red : (p[Prefs.cover] || p.red)
    readonly property color ochre:  p.ochre
    readonly property color indigo: p.indigo
    readonly property color pine:   p.pine

    // ── type ────────────────────────────────────────────────
    readonly property string serif: "EB Garamond"
    readonly property string mono:  "Monaspace Xenon"   // literal strings only
    readonly property int    size:  15

    // ── cursor theme to use for the current mode ────────────
    readonly property string cursorTheme: dark ? "rice-ink-light" : "rice-ink-dark"

    // ── gsetting sync ───────────────────────────────────────
    // Switch right now (what the transition calls when the screen is covered).
    function apply(toDark) {
        dark = toDark;
        setter.exec(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme",
                     toDark ? "prefer-dark" : "prefer-light"]);
        syncApps(toDark);
    }
    // cursor, niri colours, kitty, fastfetch... (bin/rice-theme). Silent if not installed.
    function syncApps(toDark) {
        Quickshell.execDetached(["sh", "-c", '"$HOME/.local/bin/rice-theme" ' + (toDark ? "dark" : "light") + " " + Prefs.cover]);
    }
    // Switch with the configured page-turn. Origin is where the toggle was clicked (optional).
    function toggle(ox, oy, screenName) { PageTurn.start(!dark, ox, oy, screenName) }

    Process {
        command: ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.dark = text.indexOf("prefer-dark") >= 0 }
    }
    Process {
        command: ["gsettings", "monitor", "org.gnome.desktop.interface", "color-scheme"]
        running: true
        stdout: SplitParser { onRead: data => root.dark = data.indexOf("prefer-dark") >= 0 }
    }
    Process { id: setter }
}
