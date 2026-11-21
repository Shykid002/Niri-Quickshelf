import QtQuick
import qs
import qs.components
import qs.services

// Design 5, "Verse": the day's line set large, with a cover-colour bar down the left edge.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    Rectangle { x: 0; y: 0; width: 44 * root.u; height: parent.height; color: Theme.cover }

    Column {
        x: 170 * root.u; y: 230 * root.u
        width: root.width * 0.62
        spacing: 26 * root.u
        Txt { width: parent.width; wrapMode: Text.WordWrap; lineHeight: 1.04
              text: Prefs.verse ? Almanac.verse.text : Almanac.weekday + ", " + Almanac.dateWords.replace("The ", "")
              font.pixelSize: 78 * root.u }
        Rectangle { width: 112 * root.u; height: 1; color: Theme.ink }
        Txt { visible: Prefs.verse; text: Almanac.verse.by; font.pixelSize: 24 * root.u; color: Theme.muted }
    }
    Txt { x: 170 * root.u; y: 820 * root.u; text: Almanac.dateWords; font.pixelSize: 19 * root.u; color: Theme.muted }
    Txt { anchors.right: parent.right; anchors.rightMargin: 110 * root.u; y: 820 * root.u
          text: Almanac.coverNo + "   " + Almanac.roman; font.pixelSize: 17 * root.u; color: Theme.muted }
}
