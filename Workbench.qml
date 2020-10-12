import QtQuick 2.4

import QtQuick 2.4
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Pane {
    id: root

    property string colorKey
    property int index: 0

    width: 400
    height: 400
    background: FastBlur {
        opacity: 0.7
        radius: 25
    }
    property var tileObj: tile

    MouseArea {
        id: mouseArea
        width: 64
        height: 64
        drag.target: tile
        drag.threshold: 5

        Rectangle {
            id: tile
            width: 64
            height: 64

            //            anchors.verticalCenter: parent.verticalCenter
            //            anchors.horizontalCenter: parent.horizontalCenter
            color: colorKey

            Drag.keys: [colorKey]
            Drag.active: mouseArea.drag.active
            Drag.hotSpot.x: 32
            Drag.hotSpot.y: 32

            Text {
                id: name
                text: index
                color: "red"
            }
        }
    }
}
