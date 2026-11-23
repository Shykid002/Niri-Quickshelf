import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Settings: categories | setting | control. The chosen option carries the corner brackets.
// Layout measured from the reference frame (770 x 410, rows 49px apart).
FloatingWindow {
    id: win
    title: "Settings"
    implicitWidth: 770; implicitHeight: 410
    color: Theme.paper
    onVisibleChanged: if (!visible) SettingsApp.open = false

    property string page: "look"

    readonly property var cats: [["look", "Look"], ["windows", "Windows"], ["input", "Input"],
                                 ["terminal", "Terminal"], ["session", "Session"]]

    // type: options | swatches | toggle.  options: [value, label].  get/set read and write Prefs.
    readonly property var pages: ({
        look: [
            { label: "Theme", type: "options", options: [["paper", "Paper"], ["ink", "Ink"]],
              get: () => Theme.dark ? "ink" : "paper",
              set: v => { if ((v === "ink") !== Theme.dark) Theme.toggle() } },
            { label: "Theme change", type: "options",
              options: [["held", "Held page"], ["leaf", "Leaf"], ["ink", "Ink"], ["none", "None"]],
              get: () => Prefs.themeChange, set: v => { Prefs.themeChange = v } },
            { label: "Cover", type: "swatches",
              options: [["mix"], ["red"], ["indigo"], ["ochre"], ["pine"], ["plum"], ["umber"], ["slate"], ["moss"]],
              get: () => Prefs.cover, set: v => { Prefs.cover = v; Theme.syncApps(Theme.dark) } },
            { label: "Cover scales", type: "toggle", get: () => Prefs.coverScales, set: v => { Prefs.coverScales = v } },
            { label: "Verse", type: "toggle", get: () => Prefs.verse, set: v => { Prefs.verse = v } },
            { label: "Motion", type: "options", options: [["quick", "Quick"], ["usual", "Usual"], ["slow", "Slow"]],
              get: () => Prefs.motion, set: v => { Prefs.motion = v } }
        ],
        windows: [
            { label: "Gaps", type: "options", options: [["none", "None"], ["small", "Small"], ["usual", "Usual"]],
              get: () => Prefs.gaps, set: v => { Prefs.gaps = v } },
            { label: "Border", type: "options", options: [["thin", "Thin"], ["usual", "Usual"], ["thick", "Thick"]],
              get: () => Prefs.border, set: v => { Prefs.border = v } }
        ],
        input: [
            { label: "Tap to click", type: "toggle", get: () => Prefs.tap, set: v => { Prefs.tap = v } },
            { label: "Natural scroll", type: "toggle", get: () => Prefs.natural, set: v => { Prefs.natural = v } }
        ],
        terminal: [
            { label: "Font size", type: "options", options: [["small", "Small"], ["usual", "Usual"], ["large", "Large"]],
              get: () => Prefs.fontSize, set: v => { Prefs.fontSize = v } }
        ],
        session: [
            { label: "Lock after", type: "options", options: [[0, "Never"], [5, "5 min"], [12, "12 min"], [30, "30 min"]],
              get: () => Prefs.lockMinutes, set: v => { Prefs.lockMinutes = v } },
            { label: "Confirm power", type: "toggle", get: () => Prefs.confirmPower, set: v => { Prefs.confirmPower = v } }
        ]
    })

    function swatch(v) {
        return v === "mix" ? "transparent" : (Theme[v] || Theme.red);
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: SettingsApp.open = false

        Rectangle { width: 33; height: 33; color: Theme.cover }
        Txt { x: 53; y: 18; text: "Settings"; font.pixelSize: 26 }
        Rectangle { x: 53; y: 68; width: parent.width - 106; height: 1; color: Theme.ink }

        // categories
        Column {
            x: 53; y: 79
            Repeater {
                model: win.cats
                delegate: Item {
                    id: cat
                    required property var modelData
                    readonly property bool sel: win.page === modelData[0]
                    width: 120; height: 49
                    Txt { anchors.verticalCenter: parent.verticalCenter; text: cat.modelData[1]; font.pixelSize: 17
                          color: cat.sel ? Theme.ink : Theme.muted }
                    Item { anchors { fill: parent; topMargin: 12; bottomMargin: 12; rightMargin: 40 } Bracket { active: cat.sel } }
                    MouseArea { cursorShape: Qt.PointingHandCursor; anchors.fill: parent; onClicked: win.page = cat.modelData[0] }
                }
            }
        }

        // settings of the chosen category
        Column {
            x: 207; y: 79
            Repeater {
                model: win.pages[win.page]
                delegate: Item {
                    id: row
                    required property var modelData
                    width: 520; height: 49

                    Txt { anchors.verticalCenter: parent.verticalCenter; text: row.modelData.label; color: Theme.muted; font.pixelSize: 16 }

                    Row {   // text options
                        visible: row.modelData.type === "options"
                        x: 159; anchors.verticalCenter: parent.verticalCenter; spacing: 28
                        Repeater {
                            model: row.modelData.type === "options" ? row.modelData.options : []
                            delegate: Item {
                                id: opt
                                required property var modelData
                                readonly property bool sel: row.modelData.get() === modelData[0]
                                width: label.implicitWidth; height: 28
                                Txt { id: label; anchors.verticalCenter: parent.verticalCenter; text: opt.modelData[1]
                                      font.pixelSize: 16; color: opt.sel ? Theme.ink : Theme.muted }
                                Item { anchors { fill: parent; margins: -5 } Bracket { active: opt.sel } }
                                MouseArea { cursorShape: Qt.PointingHandCursor; anchors.fill: parent; onClicked: row.modelData.set(opt.modelData[0]) }
                            }
                        }
                    }

                    Row {   // colour swatches
                        visible: row.modelData.type === "swatches"
                        x: 159; anchors.verticalCenter: parent.verticalCenter; spacing: 16
                        Repeater {
                            model: row.modelData.type === "swatches" ? row.modelData.options : []
                            delegate: Item {
                                id: sw
                                required property var modelData
                                readonly property bool sel: row.modelData.get() === modelData[0]
                                width: 20; height: 20
                                Rectangle { anchors.fill: parent; visible: sw.modelData[0] !== "mix"; color: win.swatch(sw.modelData[0]) }
                                Grid {   // "mix": four colours
                                    visible: sw.modelData[0] === "mix"; anchors.fill: parent; columns: 2
                                    Repeater {
                                        model: [Theme.indigo, Theme.red, Theme.pine, Theme.ochre]
                                        delegate: Rectangle { required property var modelData; width: 10; height: 10; color: modelData }
                                    }
                                }
                                Item { anchors { fill: parent; margins: -6 } Bracket { active: sw.sel } }
                                MouseArea { cursorShape: Qt.PointingHandCursor; anchors.fill: parent; onClicked: row.modelData.set(sw.modelData[0]) }
                            }
                        }
                    }

                    SquareToggle {   // switches
                        visible: row.modelData.type === "toggle"
                        x: 159; anchors.verticalCenter: parent.verticalCenter
                        selfToggle: false
                        checked: row.modelData.type === "toggle" ? row.modelData.get() : false
                        onToggled: v => row.modelData.set(v)
                    }
                }
            }
        }
    }
}

