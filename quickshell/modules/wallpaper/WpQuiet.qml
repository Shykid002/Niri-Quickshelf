import QtQuick
import qs
import qs.components
import qs.services

// Design 3, "Quiet": almost nothing. A huge faint day numeral, one small cover-colour square, a few words.
Item {
    id: root
    anchors.fill: parent
    property real u: height / 900
    Rectangle { anchors.fill: parent; color: Theme.paper }

    Txt {   // the faint numeral, cropped by the bottom edge
        x: -30 * root.u; y: 960 * root.u - baselineOffset
        text: Almanac.numeral; font.pixelSize: 700 * root.u; color: Theme.block
        font.features: ({ "onum": 1, "pnum": 1 })
    }
    Rectangle { x: root.width - 300 * root.u; y: 170 * root.u; width: 74 * root.u; height: 74 * root.u; color: Theme.cover }
    Txt { x: root.width - 300 * root.u; y: 262 * root.u; text: Almanac.coverNo; font.pixelSize: 16 * root.u; color: Theme.muted }

    Txt { anchors.right: parent.right; anchors.rightMargin: 120 * root.u; y: 742 * root.u - baselineOffset
          text: Almanac.weekday; font.pixelSize: 46 * root.u }
    Txt { anchors.right: parent.right; anchors.rightMargin: 120 * root.u; y: 782 * root.u - baselineOffset
          text: Almanac.dateWords; font.pixelSize: 19 * root.u; color: Theme.muted }
    CropMark { corner: "tl"; x: 61 * root.u; y: 89 * root.u; arm: 21 * root.u }
}
