import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        visible: OskState.open && (OskState.screenName === "" || OskState.screenName === win.screen.name)

        anchors { bottom: true; left: true; right: true }
        implicitHeight: 236
        color: Theme.paper

        WlrLayershell.namespace: "rice-osk"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Auto

        Rectangle { anchors { top: parent.top; left: parent.left; right: parent.right } height: 1; color: Theme.ink }

        readonly property bool isUpper: OskState.shifted || OskState.caps
        readonly property bool isAra: OskState.layout === "ARA"
        readonly property bool isSym: OskState.symbols

        // Each key entry is [displayLabel, actualTextToSend]
        function k(disp, val) { return { disp: disp, val: val !== undefined ? val : disp }; }

        readonly property var row0: isSym
            ? (isUpper ? new Array(k("¹"),k("²"),k("³"),k("⁴"),k("⁵"),k("⁶"),k("⁷"),k("⁸"),k("⁹"),k("⁰"),k("±"),k("≠"))
                       : new Array(k("1"),k("2"),k("3"),k("4"),k("5"),k("6"),k("7"),k("8"),k("9"),k("0"),k("~"),k("`")))
            : (isAra
                ? (isUpper ? new Array(k("!"),k("@"),k("#"),k("$"),k("%"),k("^"),k("&"),k("*"),k("("),k(")"),k("_"),k("+"))
                           : new Array(k("١"),k("٢"),k("٣"),k("٤"),k("٥"),k("٦"),k("٧"),k("٨"),k("٩"),k("٠"),k("-"),k("=")))
                : (isUpper ? new Array(k("!"),k("@"),k("#"),k("$"),k("%"),k("^"),k("&"),k("*"),k("("),k(")"),k("_"),k("+"))
                           : new Array(k("1"),k("2"),k("3"),k("4"),k("5"),k("6"),k("7"),k("8"),k("9"),k("0"),k("-"),k("="))))

        readonly property var row1: isSym
            ? (isUpper ? new Array(k("€"),k("£"),k("¥"),k("¢"),k("₹"),k("₦"),k("°"),k("•"),k("§"),k("¶"),k("©"),k("®"))
                       : new Array(k("!"),k("@"),k("#"),k("$"),k("%"),k("^"),k("&"),k("*"),k("("),k(")"),k("_"),k("+")))
            : (isAra
                ? (isUpper ? new Array(k("◌َ","َ"),k("◌ً","ً"),k("◌ُ","ُ"),k("◌ٌ","ٌ"),k("لإ"),k("إ"),k("‘"),k("÷"),k("×"),k("؛"),k("<"),k(">"))
                           : new Array(k("ض"),k("ص"),k("ث"),k("ق"),k("ف"),k("غ"),k("ع"),k("ه"),k("خ"),k("ح"),k("ج"),k("د")))
                : (isUpper ? new Array(k("Q"),k("W"),k("E"),k("R"),k("T"),k("Y"),k("U"),k("I"),k("O"),k("P"),k("{"),k("}"))
                           : new Array(k("q"),k("w"),k("e"),k("r"),k("t"),k("y"),k("u"),k("i"),k("o"),k("p"),k("["),k("]"))))

        readonly property var row2: isSym
            ? (isUpper ? new Array(k("«"),k("»"),k("‹"),k("›"),k("„"),k("“"),k("”"),k("‘"),k("’"),k("…"),k("—"),k("–"))
                       : new Array(k("-"),k("="),k("["),k("]"),k("{"),k("}"),k("\\"),k("|"),k(";"),k(":"),k("'")))
            : (isAra
                ? (isUpper ? new Array(k("◌ِ","ِ"),k("◌ٍ","ٍ"),k("]"),k("["),k("لأ"),k("أ"),k("ـ"),k("،"),k("/"),k(":"),k("\""))
                           : new Array(k("ش"),k("س"),k("ي"),k("ب"),k("ل"),k("ا"),k("ت"),k("ن"),k("م"),k("ك"),k("ط")))
                : (isUpper ? new Array(k("A"),k("S"),k("D"),k("F"),k("G"),k("H"),k("J"),k("K"),k("L"),k(":"),k("\""))
                           : new Array(k("a"),k("s"),k("d"),k("f"),k("g"),k("h"),k("j"),k("k"),k("l"),k(";"),k("'"))))

        readonly property var row3: isSym
            ? (isUpper ? new Array(k("≈"),k("≤"),k("≥"),k("×"),k("÷"),k("√"),k("∞"),k("π"),k("✓"),k("✗"),k("★"),k("♦"))
                       : new Array(k("\""),k("<"),k(">"),k(","),k("."),k("/"),k("?"),k("؟"),k("،"),k("؛")))
            : (isAra
                ? (isUpper ? new Array(k("◌ّ","ّ"),k("◌ْ","ْ"),k("}"),k("{"),k("لآ"),k("آ"),k("’"),k(","),k("."),k("؟"))
                           : new Array(k("ئ"),k("ء"),k("ؤ"),k("ر"),k("لا"),k("ى"),k("ة"),k("و"),k("ز"),k("ظ")))
                : (isUpper ? new Array(k("Z"),k("X"),k("C"),k("V"),k("B"),k("N"),k("M"),k("<"),k(">"),k("?"))
                           : new Array(k("z"),k("x"),k("c"),k("v"),k("b"),k("n"),k("m"),k(","),k("."),k("/"))))

        component KeyCap: Item {
            id: cap
            property string label: ""
            property bool active: false
            property bool accent: false
            property real keyW: 48
            signal triggered()

            width: keyW
            height: 38

            Rectangle {
                anchors.fill: parent
                color: cap.active || cap.accent
                       ? Theme.cover
                       : (ma.pressed ? Theme.ink : Theme.block)
                border.width: 1
                border.color: ma.containsMouse ? Theme.cover : Theme.rule
            }

            Txt {
                anchors.centerIn: parent
                text: cap.label
                font.pixelSize: (OskState.layout === "ARA" || OskState.symbols) && cap.label.length <= 2 ? 18 : 15
                font.bold: cap.active || cap.accent
                color: cap.active || cap.accent || ma.pressed ? Theme.paper : Theme.ink
            }

            Bracket { active: ma.containsMouse; color: cap.active ? Theme.paper : Theme.cover }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: cap.triggered()
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 6

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                Repeater {
                    model: win.row0
                    delegate: KeyCap {
                        required property var modelData
                        label: modelData.disp
                        keyW: 52
                        onTriggered: OskState.sendText(modelData.val)
                    }
                }
                KeyCap { label: "⌫"; keyW: 78; onTriggered: OskState.sendKey("BackSpace") }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                KeyCap { label: "Tab"; keyW: 66; onTriggered: OskState.sendKey("Tab") }
                Repeater {
                    model: win.row1
                    delegate: KeyCap {
                        required property var modelData
                        label: modelData.disp
                        keyW: 52
                        onTriggered: OskState.sendText(modelData.val)
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                KeyCap {
                    label: "Caps"; keyW: 78; active: OskState.caps
                    onTriggered: { OskState.caps = !OskState.caps; OskState.shifted = false; }
                }
                Repeater {
                    model: win.row2
                    delegate: KeyCap {
                        required property var modelData
                        label: modelData.disp
                        keyW: 52
                        onTriggered: OskState.sendText(modelData.val)
                    }
                }
                KeyCap { label: "Return ↵"; keyW: 92; accent: true; onTriggered: OskState.sendKey("Return") }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                KeyCap {
                    label: OskState.symbols ? (OskState.shifted ? "1/2" : "2/2") : "⇧ Shift"
                    keyW: 96; active: OskState.shifted
                    onTriggered: OskState.shifted = !OskState.shifted
                }
                Repeater {
                    model: win.row3
                    delegate: KeyCap {
                        required property var modelData
                        label: modelData.disp
                        keyW: 52
                        onTriggered: OskState.sendText(modelData.val)
                    }
                }
                KeyCap {
                    label: OskState.symbols ? "Sym" : "⇧"
                    keyW: 74; active: OskState.shifted
                    onTriggered: OskState.shifted = !OskState.shifted
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                KeyCap {
                    label: OskState.layout === "US" ? "US · عربي" : "ARA · EN"
                    keyW: 104; accent: true
                    onTriggered: OskState.toggleLayout()
                }
                KeyCap {
                    label: OskState.symbols ? (OskState.layout === "US" ? "ABC" : "أبج") : "?123"
                    keyW: 68; active: OskState.symbols
                    onTriggered: OskState.toggleSymbols()
                }
                KeyCap {
                    label: OskState.layout === "US" ? "Space" : "مسافة"
                    keyW: 274
                    onTriggered: OskState.sendText(" ")
                }
                KeyCap { label: "←"; keyW: 48; onTriggered: OskState.sendKey("Left") }
                KeyCap { label: "↓"; keyW: 48; onTriggered: OskState.sendKey("Down") }
                KeyCap { label: "↑"; keyW: 48; onTriggered: OskState.sendKey("Up") }
                KeyCap { label: "→"; keyW: 48; onTriggered: OskState.sendKey("Right") }
                KeyCap { label: "✕"; keyW: 52; onTriggered: OskState.open = false }
            }
        }
    }
}
