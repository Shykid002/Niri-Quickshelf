import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Phase 3 test page: every primitive in every state.
// Enable with:  RICE_PRIMITIVES_TEST=1 qs -c rice
FloatingWindow {
    title: "rice · primitives"
    implicitWidth: 360
    implicitHeight: 460
    color: Theme.paper

    Column {
        anchors { left: parent.left; top: parent.top; margins: 28 }
        spacing: 20

        Row {
            spacing: 14
            SquareToggle { checked: true }
            SquareToggle { checked: false }
            Square { filled: true }
            Square { filled: false }
            Txt { text: "toggles · markers"; color: Theme.muted }
        }

        Grid {
            columns: 2; spacing: 2
            Tile { id: wifi; width: 182; title: "Wi-Fi"; detail: "Paper House"; on: true; onClicked: on = !on }
            Tile { id: bt; width: 90; title: "Bluetooth"; on: true; accent: Theme.indigo; onClicked: on = !on }
            Tile { width: 90; title: "Ink"; on: Theme.dark; onClicked: Theme.toggle() }
            Tile { width: 90; title: "Quiet"; on: false; onClicked: on = !on }
        }

        BlockSlider { label: "Sound"; value: Audio.volume * 100; onMoved: v => Audio.setVolume(v) }
        BlockSlider { label: "Light"; value: Brightness.percent; onMoved: v => Brightness.set(v) }

        Txt { text: "Hover anything: brackets appear. Click “Ink” to flip theme."; color: Theme.muted; font.pixelSize: 13 }
    }
}
