import QtQuick 2.12

import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import CWorkspace 1.0
import CActorItem 1.0

Pane {
    id: root
    clip: true

    property string colorKey
    property string id
    property CWorkspace workspace
    property var actorFormMap
    property alias flickableArea: flickable
    property alias destArea: destArea
    property alias movingShape: movingShape
    property alias followItem: followItem

    width: 400
    height: 400

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: destArea.height
        contentWidth: destArea.width

        ScrollBar.vertical: ScrollBar {}
        ScrollBar.horizontal: ScrollBar {}

        DropArea {
            id: destArea
            height: 2160
            width: 3840
            z: -1

            Loader {
                active: false
                id: followItem
                opacity: 0.4
            }
        }

        Shape {
            id: movingShape
            anchors.fill: parent

            property point startPoint: Qt.point(0, 0)
            property point endPoint: Qt.point(0, 0)

            ShapePath {
                strokeColor: "aquamarine"
                strokeWidth: 6
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                strokeStyle: ShapePath.DashLine

                property int joinStyleIndex: 0

                property variant styles: [ShapePath.BevelJoin, ShapePath.MiterJoin, ShapePath.RoundJoin]

                joinStyle: styles[joinStyleIndex]

                startX: movingShape.startPoint.x
                startY: movingShape.startPoint.y
                PathLine {
                    x: movingShape.endPoint.x
                    y: movingShape.endPoint.y
                }
            }
        }
    }
}
