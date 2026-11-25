pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias quiet: ad.quiet
    property alias wallpaperPaper: ad.wallpaperPaper
    property alias wallpaperInk: ad.wallpaperInk

    // Look
    property alias themeChange: ad.themeChange
    property alias cover: ad.cover
    property alias coverScales: ad.coverScales
    property alias verse: ad.verse
    property alias motion: ad.motion

    // Windows / Input / Cursor / Terminal
    property alias gaps: ad.gaps
    property alias border: ad.border
    property alias kbLayout: ad.kbLayout                // "us" | "ara"
    property alias focusFollowsMouse: ad.focusFollowsMouse
    property alias tap: ad.tap
    property alias natural: ad.natural
    property alias dwt: ad.dwt
    property alias cursorStyle: ad.cursorStyle          // "box" | "curly" | "ring"
    property alias cursorSize: ad.cursorSize            // 20 | 24 | 28 | 32
    property alias cursorTrail: ad.cursorTrail          // "off" | "comet" | "sparks"
    property alias musicRing: ad.musicRing
    property alias fontSize: ad.fontSize

    // Session
    property alias lockMinutes: ad.lockMinutes
    property alias confirmPower: ad.confirmPower
    property alias ultraSaver: ad.ultraSaver
    property alias ultraRestore: ad.ultraRestore

    readonly property real speed: motion === "quick" ? 0.6 : motion === "slow" ? 1.6 : 1.0

    Process { command: new Array("mkdir", "-p", Quickshell.env("HOME") + "/.config/rice"); running: true }

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
            property string cover: "sky"
            property bool quiet: false
            property int wallpaperPaper: 0
            property int wallpaperInk: 0
            property bool coverScales: true
            property bool verse: true
            property string motion: "usual"
            property string gaps: ""
            property string border: ""
            property string kbLayout: "us"
            property bool focusFollowsMouse: false
            property bool tap: true
            property bool natural: true
            property bool dwt: true
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
