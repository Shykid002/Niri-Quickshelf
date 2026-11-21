import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs
import qs.components
import qs.services

// Opened by clicking the tray square: every tray app as a row.
//   click = activate (or its menu if menu-only)   right click = menu   middle click = secondary action
PopupFrame {
    id: root
    implicitWidth: 300

    Item {
        width: parent.width; height: 45
        Txt { x: 22; anchors.verticalCenter: parent.verticalCenter; text: "Tray"; font.pixelSize: 17 }
        Mono { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
               text: SystemTray.items.values.length; color: Theme.muted; font.pixelSize: 12 }
    }
    Rectangle { width: parent.width; height: 1; color: Theme.rule }

    Txt { visible: SystemTray.items.values.length === 0; x: 22; text: "No apps in the tray"; color: Theme.muted
          height: visible ? 44 : 0 }

    Repeater {
        model: SystemTray.items
        delegate: ListRow {
            id: app
            required property var modelData
            rowHeight: 34
            function menu(mx, my) {
                const p = app.mapToItem(null, mx, my);
                if (app.modelData.hasMenu) app.modelData.display(QsWindow.window, p.x, p.y);
            }
            onClicked: {
                if (modelData.onlyMenu) { menu(width / 2, height); return; }
                modelData.activate();
                Popups.close();
            }
            IconImage { x: 22; anchors.verticalCenter: parent.verticalCenter; implicitSize: 18; source: app.modelData.icon }
            Txt { x: 52; anchors.verticalCenter: parent.verticalCenter; font.pixelSize: 15
                  text: app.modelData.title || app.modelData.tooltipTitle || app.modelData.id
                  elide: Text.ElideRight; width: parent.width - 52 - 80 }
            Txt { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
                  text: app.modelData.status === Status.NeedsAttention ? "attention" : app.modelData.status === Status.Active ? "active" : ""
                  color: app.modelData.status === Status.NeedsAttention ? Theme.red : Theme.muted; font.pixelSize: 12 }
            MouseArea {
                anchors.fill: parent; acceptedButtons: Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) app.menu(mouse.x, mouse.y);
                    else app.modelData.secondaryActivate();
                }
            }
        }
    }
    Item { width: parent.width; height: 8 }
}
