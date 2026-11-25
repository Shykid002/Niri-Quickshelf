import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

// Top bar, 27px. Left: workspace box + pills. Centre: window. Right: status, clock block.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData
        anchors { top: true; left: true; right: true }
        implicitHeight: 27
        color: Theme.paper
        WlrLayershell.namespace: "rice-bar"

        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.rule }

        // ── left ──
        Rectangle {
            id: wsBox
            width: 28; height: 27; color: Theme.cover
            Txt { anchors.centerIn: parent; color: Theme.paper; font.pixelSize: 13
                  text: Niri.available ? Niri.focusedIndex : "–" }
            Bracket { active: wsArea.containsMouse; color: Theme.paper }
            MouseArea { cursorShape: Qt.PointingHandCursor; id: wsArea; anchors.fill: parent; hoverEnabled: true; onClicked: Niri.toggleOverview() }
        }
        Pills { anchors { left: wsBox.right; leftMargin: 11; verticalCenter: parent.verticalCenter } }

        // ── centre ──
        Row {
            anchors.centerIn: parent
            spacing: 6
            visible: Niri.focusedApp !== ""
            Txt { text: Niri.focusedApp; color: Theme.muted; font.pixelSize: 14 }
            Txt { text: Niri.focusedTitle; font.pixelSize: 14; elide: Text.ElideRight
                  width: Math.min(implicitWidth, win.width * 0.3) }
        }

        // ── right ──
        Rectangle {
            id: clock
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width: 144; color: Theme.ink
            Row {
                anchors.centerIn: parent
                spacing: 8
                Txt { text: Almanac.shortDate; color: Theme.paper; font.pixelSize: 14 }
                Mono { text: Almanac.timeText; color: Theme.paper; font.pixelSize: 13; font.bold: true }
            }
            Bracket { active: clockArea.containsMouse; color: Theme.paper }
            MouseArea { cursorShape: Qt.PointingHandCursor; id: clockArea; anchors.fill: parent; hoverEnabled: true
                        onClicked: Drawer.toggle("day", win.screen) }
        }

        Row {
            anchors { right: clock.left; top: parent.top; bottom: parent.bottom }

            TrayStrip { window: win }
            BarButton {   // Wi-Fi: opens the network card; name shows on hover
                id: netBtn
                open: Popups.current === "net" && Popups.screenName === win.screen.name
                onClicked: Popups.toggle("net", win.screen, win.width - netBtn.mapToItem(null, netBtn.width, 0).x)
                Glyph { kind: "signal"; level: Network.connected ? Network.signal / 100 : 0; tone: netBtn.tone }
                Mono {
                    visible: (netBtn.hovered || netBtn.open) && Network.connected
                    text: Network.ssid; color: netBtn.tone; font.pixelSize: 11
                    elide: Text.ElideRight; width: Math.min(implicitWidth, 90)
                }
            }
            BarButton {   // notifications: latest one reveals on hover / on arrival; click opens the card
                id: notBtn
                open: Popups.current === "notes" && Popups.screenName === win.screen.name
                onClicked: Popups.toggle("notes", win.screen, win.width - notBtn.mapToItem(null, notBtn.width, 0).x)
                Glyph { kind: "note"; flag: Notifs.count > 0; tone: notBtn.tone }
                Txt {
                    visible: notBtn.hovered || notBtn.open || Notifs.flash
                    text: Notifs.count === 0 ? "Nothing waiting"
                          : Notifs.count + "  " + (Notifs.latest ? Notifs.latest.summary : "")
                    color: notBtn.tone; font.pixelSize: 12
                    elide: Text.ElideRight; width: Math.min(implicitWidth, 220)
                }
            }
            BarButton {
                id: volBtn
                open: Popups.current === "sound" && Popups.screenName === win.screen.name
                onClicked: Popups.toggle("sound", win.screen, win.width - volBtn.mapToItem(null, volBtn.width, 0).x)
                Glyph { kind: "volume"; level: Audio.volume; flag: Audio.muted; tone: volBtn.tone }
                Mono { visible: volBtn.hovered || volBtn.open; color: volBtn.tone; font.pixelSize: 11
                       text: Audio.muted ? "muted" : Math.round(Audio.volume * 100) + "%" }
            }
            BarButton {   // battery: percentage on hover, profile card on click
                id: batBtn
                visible: Battery.present
                open: Popups.current === "power" && Popups.screenName === win.screen.name
                onClicked: Popups.toggle("power", win.screen, win.width - batBtn.mapToItem(null, batBtn.width, 0).x)
                Glyph {
                    kind: "battery"; level: Battery.level
                    tone: batBtn.open ? Theme.paper : Battery.tone
                }
                Mono {
                    visible: batBtn.hovered || batBtn.open
                    text: Battery.percent + "%"; color: batBtn.tone; font.pixelSize: 11
                }
            }
            BarButton {   // on-screen keyboard: geometric glyph + US/ARA label on hover or open
                id: oskBtn
                open: OskState.open && (OskState.screenName === "" || OskState.screenName === win.screen.name)
                onClicked: OskState.toggle(win.screen)
                Glyph { kind: "keyboard"; tone: oskBtn.tone }
                Mono {
                    visible: oskBtn.hovered || oskBtn.open
                    text: OskState.layout
                    color: oskBtn.tone
                    font.pixelSize: 11
                }
            }
            BarButton {   // wallpaper: pick one for the active theme
                id: wallBtn
                open: Popups.current === "wall" && Popups.screenName === win.screen.name
                onClicked: Popups.toggle("wall", win.screen, win.width - wallBtn.mapToItem(null, wallBtn.width, 0).x)
                Glyph { kind: "wall"; tone: wallBtn.tone }
            }
            BarButton {
                id: themeBtn
                onClicked: {
                    const pt = themeBtn.mapToItem(null, themeBtn.width / 2, themeBtn.height / 2);
                    Theme.toggle(pt.x, pt.y, win.screen.name);
                }
                Glyph { kind: "theme"; tone: themeBtn.tone }
            }
            BarButton {   // session panel
                id: pwrBtn
                open: Session.open && Session.screenName === win.screen.name
                onClicked: Session.toggle(win.screen)
                Glyph { kind: "power"; tone: pwrBtn.tone }
                Txt { visible: pwrBtn.hovered || pwrBtn.open; text: "Session"; color: pwrBtn.tone; font.pixelSize: 12 }
            }
        }
    }
}
