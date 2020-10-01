import QtQuick 2.4

import QtQuick 2.4
import QtQuick.Controls 2.12

Item {
    id: root

    property string colorKey

    width: 400
    height: 400

    property var tileObj: tile

    Pane {
        anchors.fill: parent
        anchors.margins: 10
        opacity: 0.7
    }

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
        }
    }
}
