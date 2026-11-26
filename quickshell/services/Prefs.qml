pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Persistent settings, stored in ~/.config/rice/settings.json. The Settings window edits these.
Singleton {
    id: root

    // Quiet: no sounds (except the timer alarm) and no automatic reveal of new notifications.
    property alias quiet: ad.quiet
    property alias wallpaperPaper: ad.wallpaperPaper    // 0..4, chosen with the bar's wallpaper button
    property alias wallpaperInk: ad.wallpaperInk

    // Look
    property alias themeChange: ad.themeChange          // "held" | "leaf" | "ink" | "none"
    property alias cover: ad.cover                      // "mix" or any name in assets/covers.tsv
    property alias coverScales: ad.coverScales          // wallpaper cover scales with screen height
    property alias verse: ad.verse                      // show the verse on the wallpaper
    property alias motion: ad.motion                    // "quick" | "usual" | "slow"
    // Windows / Input / Terminal  ("" = not set by the rice, niri/Ghostty keep their own)
    property alias gaps: ad.gaps                        // "none" | "small" | "usual"
    property alias border: ad.border                    // "thin" | "usual" | "thick"
    property alias tap: ad.tap
    property alias natural: ad.natural
    property alias focusFollowsMouse: ad.focusFollowsMouse        // niri focus-follows-mouse
    property alias dwt: ad.dwt                          // touchpad: disable while typing
    property alias kbLayout: ad.kbLayout                    // keyboard layout: "us" | "ara"
    property alias cursorStyle: ad.cursorStyle          // "box" | "curly" | "ring"
    property alias cursorSize: ad.cursorSize            // 20 | 24 | 28 | 32
    property alias cursorTrail: ad.cursorTrail          // "off" | "comet" | "sparks"   (CursorFxLayer)
    property alias musicRing: ad.musicRing              // spectrum ring around the pointer while music plays
    property alias fontSize: ad.fontSize                // "small" | "usual" | "large"
    // Session
    property alias lockMinutes: ad.lockMinutes          // 0 = never
    property alias confirmPower: ad.confirmPower
    // Power profile "Ultra-Saver" (power-saver + dim screen) and the brightness to go back to
    property alias ultraSaver: ad.ultraSaver
    property alias ultraRestore: ad.ultraRestore

    readonly property real speed: motion === "quick" ? 0.6 : motion === "slow" ? 1.6 : 1.0

    Process { command: ["mkdir", "-p", Quickshell.env("HOME") + "/.config/rice"]; running: true }

    FileView {
        path: Quickshell.env("HOME") + "/.config/rice/settings.json"
        blockLoading: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        adapter: JsonAdapter {
            id: ad
            property string themeChange: "held"
            property string cover: "red"
            property bool quiet: false
            property int wallpaperPaper: 0
            property int wallpaperInk: 0
            property bool coverScales: true
            property bool verse: true
            property string motion: "usual"
            property string gaps: ""
            property string border: ""
            property bool tap: true
            property bool natural: true
            property bool focusFollowsMouse: false
            property bool dwt: true
            property string kbLayout: "us"
            property string cursorStyle: "box"
            property int cursorSize: 24
            property string cursorTrail: "off"
            property bool musicRing: false
            property string fontSize: ""
            property int lockMinutes: 12
            property bool confirmPower: true
            property bool ultraSaver: false
            property int ultraRestore: 70
        }
    }
}
