import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Hosts the open popup on the screen it was opened from.
// A transparent catcher under it (below the bar) closes it on any outside click.
Variants {
    model: Quickshell.screens

    Scope {
        id: sc
        required property var modelData
        readonly property bool shown: Popups.current !== "" && Popups.screenName === modelData.name

        PanelWindow {   // click-outside catcher
            screen: sc.modelData
            visible: sc.shown
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            margins.top: 27
            WlrLayershell.namespace: "rice-popup-catcher"
            MouseArea { anchors.fill: parent; onClicked: Popups.close() }
        }

        PanelWindow {
            screen: sc.modelData
            visible: sc.shown
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; right: true }
            margins { top: 28; right: Popups.offset }
            implicitWidth: loader.item ? loader.item.implicitWidth : 356
            implicitHeight: Math.max(1, loader.item ? loader.item.implicitHeight : 1)
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "rice-popup"

            Loader {
                id: loader
                anchors.fill: parent
                sourceComponent: ({ net: net, sound: sound, notes: notes, tray: tray, power: power, wall: wall })[Popups.current] || null
            }
            Component { id: net;   NetPopup {} }
            Component { id: sound; SoundPopup {} }
            Component { id: notes; NotesPopup {} }
            Component { id: tray;  TrayPopup {} }
            Component { id: power; PowerPopup {} }
            Component { id: wall;  WallpaperPopup {} }
        }
    }
}
