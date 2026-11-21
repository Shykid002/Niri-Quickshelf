import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Generated wallpaper, no image file. Five designs (WpCover, WpSpines, WpQuiet, WpGrid, WpVerse);
// the paper theme and the ink theme each remember their own pick (bar > wallpaper button).
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        color: Theme.paper
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "rice-wallpaper"

        WpDesign {
            anchors.fill: parent
            index: Theme.dark ? Prefs.wallpaperInk : Prefs.wallpaperPaper
            onLoaded: item.u = Qt.binding(() => Prefs.coverScales ? win.height / 900 : 1)
        }
    }
}
