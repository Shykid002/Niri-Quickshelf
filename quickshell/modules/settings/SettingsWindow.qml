import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

FloatingWindow {
    id: win
    title: "Settings"
    implicitWidth: 770; implicitHeight: 410
    color: Theme.paper
    onVisibleChanged: if (!visible) SettingsApp.open = false

    property string page: "look"

    readonly property var cats: new Array(
        "look,Look",
        "windows,Windows",
        "input,Input",
        "cursor,Cursor",
        "terminal,Terminal",
        "session,Session"
    )

    readonly property var pages: ({
        look: new Array(
            { label: "Theme", type: "options",
              options: new Array("paper,Paper", "ink,Ink"),
              get: () => Theme.dark ? "ink" : "paper",
              set: v => { if ((v === "ink") !== Theme.dark) Theme.toggle() } },
            { label: "Theme change", type: "options",
              options: new Array("held,Held page", "leaf,Leaf", "ink,Ink", "none,None"),
              get: () => Prefs.themeChange, set: v => { Prefs.themeChange = v } },
            { label: "Cover", type: "swatches",
              options: new Array("mix").concat(Theme.coverNames),
              get: () => Prefs.cover, set: v => { Prefs.cover = v; Theme.syncApps(Theme.dark) } },
            { label: "Cover scales", type: "toggle", get: () => Prefs.coverScales, set: v => { Prefs.coverScales = v } },
            { label: "Verse", type: "toggle", get: () => Prefs.verse, set: v => { Prefs.verse = v } },
            { label: "Motion", type: "options",
              options: new Array("quick,Quick", "usual,Usual", "slow,Slow"),
              get: () => Prefs.motion, set: v => { Prefs.motion = v } }
        ),
        windows: new Array(
            { label: "Gaps", type: "options",
              options: new Array("none,None", "small,Small", "usual,Usual"),
              get: () => Prefs.gaps, set: v => { Prefs.gaps = v } },
            { label: "Border", type: "options",
              options: new Array("thin,Thin", "usual,Usual", "thick,Thick"),
              get: () => Prefs.border, set: v => { Prefs.border = v } }
        ),
        input: new Array(
            { label: "Keyboard", type: "options",
              options: new Array("us,US", "ara,ARA"),
              get: () => Prefs.kbLayout, set: v => { Prefs.kbLayout = v; if (typeof OskState !== "undefined") OskState.layout = (v === "ara" ? "ARA" : "US") } },
            { label: "Focus mouse", type: "toggle", get: () => Prefs.focusFollowsMouse, set: v => { Prefs.focusFollowsMouse = v } },
            { label: "Tap to click", type: "toggle", get: () => Prefs.tap, set: v => { Prefs.tap = v } },
            { label: "Natural scroll", type: "toggle", get: () => Prefs.natural, set: v => { Prefs.natural = v } },
            { label: "Disable typing", type: "toggle", get: () => Prefs.dwt, set: v => { Prefs.dwt = v } }
        ),
        cursor: new Array(
            { label: "Style", type: "cursorStyles",
              options: new Array("box,Box", "curly,Curly", "ring,Ring"),
              get: () => Prefs.cursorStyle, set: v => { Prefs.cursorStyle = v } },
            { label: "Size", type: "options",
              options: new Array("20,20", "24,24", "28,28", "32,32"),
              get: () => String(Prefs.cursorSize), set: v => { Prefs.cursorSize = Number(v) } },
            { label: "Trail effect", type: "options",
              options: new Array("off,Off", "comet,Comet", "sparks,Sparks"),
              get: () => Prefs.cursorTrail, set: v => { Prefs.cursorTrail = v } },
            { label: "Music ring", type: "toggle", get: () => Prefs.musicRing, set: v => { Prefs.musicRing = v } }
        ),
        terminal: new Array(
            { label: "Font size", type: "options",
              options: new Array("small,Small", "usual,Usual", "large,Large"),
              get: () => Prefs.fontSize, set: v => { Prefs.fontSize = v } }
        ),
        session: new Array(
            { label: "Lock after", type: "options",
              options: new Array("0,Never", "5,5 min", "12,12 min", "30,30 min"),
              get: () => String(Prefs.lockMinutes), set: v => { Prefs.lockMinutes = Number(v) } },
            { label: "Confirm power", type: "toggle", get: () => Prefs.confirmPower, set: v => { Prefs.confirmPower = v } }
        )
    })

    function keyOf(pair) {
        const i = pair.indexOf(",");
        return i >= 0 ? pair.slice(0, i) : pair;
    }
    function labelOf(pair) {
        const i = pair.indexOf(",");
        return i >= 0 ? pair.slice(i + 1) : pair;
    }
    function swatch(v) {
        return v === "mix" ? "transparent" : Theme.coverHex(v);
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
                    required property string modelData
                    readonly property string cid: win.keyOf(cat.modelData)
                    readonly property string clabel: win.labelOf(cat.modelData)
                    readonly property bool sel: win.page === cid
                    width: 120; height: 46
                    Txt { anchors.verticalCenter: parent.verticalCenter; text: cat.clabel; font.pixelSize: 17
                          color: cat.sel ? Theme.ink : Theme.muted }
                    Item { anchors { fill: parent; topMargin: 11; bottomMargin: 11; rightMargin: 40 } Bracket { active: cat.sel } }
                    MouseArea { cursorShape: Qt.PointingHandCursor; anchors.fill: parent; onClicked: win.page = cat.cid }
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
                            model: row.modelData.type === "options" ? row.modelData.options : new Array()
                            delegate: Item {
                                id: opt
                                required property string modelData
                                readonly property string oval: win.keyOf(opt.modelData)
                                readonly property string olabel: win.labelOf(opt.modelData)
                                readonly property bool sel: String(row.modelData.get()) === oval
                                width: label.implicitWidth; height: 28
                                Txt { id: label; anchors.verticalCenter: parent.verticalCenter; text: opt.olabel
                                      font.pixelSize: 16; color: opt.sel ? Theme.ink : Theme.muted }
                                Item { anchors { fill: parent; margins: -5 } Bracket { active: opt.sel } }
                                MouseArea { cursorShape: Qt.PointingHandCursor; anchors.fill: parent; onClicked: row.modelData.set(opt.oval) }
                            }
                        }
                    }

                    Row {   // cursor styles with live geometric preview icon
                        visible: row.modelData.type === "cursorStyles"
                        x: 159; anchors.verticalCenter: parent.verticalCenter; spacing: 26
                        Repeater {
                            model: row.modelData.type === "cursorStyles" ? row.modelData.options : new Array()
                            delegate: Item {
                                id: cs
                                required property string modelData
                                readonly property string sId: win.keyOf(cs.modelData)
                                readonly property string sLabel: win.labelOf(cs.modelData)
                                readonly property bool sel: row.modelData.get() === sId
                                width: csRow.implicitWidth; height: 28

                                Row {
                                    id: csRow
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Canvas {
                                        width: 18; height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        property color inkCol: Theme.ink
                                        property color covCol: Theme.cover
                                        onInkColChanged: requestPaint()
                                        onCovColChanged: requestPaint()
                                        onPaint: {
                                            const c = getContext("2d");
                                            c.clearRect(0, 0, width, height);
                                            if (cs.sId === "box") {
                                                c.fillStyle = covCol; c.fillRect(6, 6, 10, 10);
                                                c.fillStyle = inkCol; c.fillRect(2, 2, 6, 6);
                                            } else if (cs.sId === "curly") {
c.strokeStyle = covCol; c.lineWidth = 2.4; c.lineCap = "round";
c.beginPath(); c.moveTo(3, 3); c.quadraticCurveTo(9, 4, 11, 11); c.stroke();
c.fillStyle = inkCol; c.fillRect(4, 12, 3, 3);
c.fillStyle = covCol; c.beginPath(); c.arc(12.5, 13.5, 1.8, 0, Math.PI * 2); c.fill();
} else {
c.fillStyle = covCol;
c.beginPath(); c.arc(5, 9, 2.5, 0, Math.PI * 2); c.fill();
c.strokeStyle = covCol; c.lineWidth = 1.6;
c.beginPath(); c.arc(13, 9, 4.2, 0, Math.PI * 2); c.stroke();
}
}
}
Txt {
anchors.verticalCenter: parent.verticalCenter
text: cs.sLabel
font.pixelSize: 16
color: cs.sel ? Theme.ink : Theme.muted
}
}
Item { anchors { fill: parent; margins: -5 } Bracket { active: cs.sel } }
MouseArea { cursorShape: Qt.PointingHandCursor; anchors.fill: parent; onClicked: row.modelData.set(cs.sId) }
}
}
}
Flickable {   // colour swatches
id: swFlick
visible: row.modelData.type === "swatches"
x: 159; width: 340; height: 36
anchors.verticalCenter: parent.verticalCenter
clip: true
contentWidth: swRow.width + 16
contentHeight: height
flickableDirection: Flickable.HorizontalFlick
boundsBehavior: Flickable.StopAtBounds
Component.onCompleted: {
if (row.modelData.type !== "swatches") return;
const i = row.modelData.options.indexOf(Prefs.cover);
contentX = Math.max(0, Math.min(contentWidth - width, i * 34 - width / 2));
}
WheelHandler {
acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
onWheel: event => {
const d = event.angleDelta.x !== 0 ? event.angleDelta.x : event.angleDelta.y;
swFlick.contentX = Math.max(0, Math.min(swFlick.contentWidth - swFlick.width, swFlick.contentX - d));
}
}
Row {
id: swRow
x: 8; anchors.verticalCenter: parent.verticalCenter; spacing: 14
Repeater {
model: row.modelData.type === "swatches" ? row.modelData.options : new Array()
delegate: Item {
id: sw
required property string modelData
readonly property bool sel: row.modelData.get() === sw.modelData
width: 20; height: 20
Rectangle { anchors.fill: parent; visible: sw.modelData !== "mix"; color: win.swatch(sw.modelData) }
Grid {
visible: sw.modelData === "mix"; anchors.fill: parent; columns: 2
Repeater {
model: new Array(Theme.sky, Theme.mint, Theme.sakura, Theme.sand)
delegate: Rectangle { required property color modelData; width: 10; height: 10; color: modelData }
}
}
Item { anchors { fill: parent; margins: -6 } Bracket { active: sw.sel } }
MouseArea { cursorShape: Qt.PointingHandCursor; anchors.fill: parent; onClicked: row.modelData.set(sw.modelData) }
}
}
}
}
Rectangle {
visible: row.modelData.type === "swatches" && swFlick.contentWidth > swFlick.width
x: 159; y: 44; width: 340; height: 1; color: Theme.rule
Rectangle {
height: 1; color: Theme.ink
width: parent.width * swFlick.width / swFlick.contentWidth
x: (parent.width - width) * (swFlick.contentX / Math.max(1, swFlick.contentWidth - swFlick.width))
}
}
SquareToggle {
id: swToggle
visible: row.modelData.type === "toggle"
x: 159; anchors.verticalCenter: parent.verticalCenter
selfToggle: false
checked: row.modelData.type === "toggle" ? row.modelData.get() : false
onToggled: v => row.modelData.set(v)
}
Item {
visible: row.modelData.label === "Verse"
x: 159 + swToggle.width + 18
anchors.verticalCenter: parent.verticalCenter
width: 24; height: 24
Canvas {
id: reloadIcon
anchors.centerIn: parent
width: 16; height: 16
property color strokeColor: reloadArea.containsMouse ? Theme.cover : Theme.ink
onStrokeColorChanged: requestPaint()
Behavior on rotation { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
onPaint: {
const ctx = getContext("2d");
ctx.clearRect(0, 0, width, height);
ctx.strokeStyle = strokeColor;
ctx.fillStyle = strokeColor;
ctx.lineWidth = 1.4;
ctx.lineCap = "round";
const cx = width / 2;
const cy = height / 2;
const r = 5.6;
const a1Start = -Math.PI * 0.85;
const a1End   = -Math.PI * 0.12;
ctx.beginPath();
ctx.arc(cx, cy, r, a1Start, a1End, false);
ctx.stroke();
const tip1X = cx + r * Math.cos(a1End);
const tip1Y = cy + r * Math.sin(a1End);
ctx.beginPath();
ctx.moveTo(tip1X + 1.2, tip1Y + 1.5);
ctx.lineTo(tip1X - 3.6, tip1Y + 0.4);
ctx.lineTo(tip1X - 0.6, tip1Y - 3.2);
ctx.closePath();
ctx.fill();
const a2Start = Math.PI * 0.15;
const a2End   = Math.PI * 0.88;
ctx.beginPath();
ctx.arc(cx, cy, r, a2Start, a2End, false);
ctx.stroke();
const tip2X = cx + r * Math.cos(a2End);
const tip2Y = cy + r * Math.sin(a2End);
ctx.beginPath();
ctx.moveTo(tip2X - 1.2, tip2Y - 1.5);
ctx.lineTo(tip2X + 3.6, tip2Y - 0.4);
ctx.lineTo(tip2X + 0.6, tip2Y + 3.2);
ctx.closePath();
ctx.fill();
}
}
Bracket { active: reloadArea.containsMouse; color: Theme.cover }
MouseArea {
id: reloadArea
anchors.fill: parent
hoverEnabled: true
cursorShape: Qt.PointingHandCursor
onClicked: {
reloadIcon.rotation += 180;
Almanac.randomVerse();
}
}
}
}
}
}
}
}
