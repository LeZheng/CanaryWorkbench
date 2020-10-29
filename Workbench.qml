import QtQuick 2.4

import QtQuick 2.4
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Pane {
    id: root

    property string colorKey
    property string name

    width: 400
    height: 400

    background: FastBlur {
        opacity: 0.7
        radius: 25
    }

    DropArea {
        id: destArea
        anchors.fill: parent
        z: -1

        onEntered: {
            console.log("enter:", drag.source.x, drag.source.y)
            if (drag.supportedActions == Qt.LinkAction) {
                var p = drag.source.mapToItem(destArea, 0, 0)
                console.log("start", p)
                movingShape.startPoint = p //Qt.point(drag.source.x, drag.source.y)
            } else {
                drag.accepted = true
                followItem.source = drag.getDataAsString("form")
                followItem.active = true
            }
        }

        onPositionChanged: {
            if (drag.supportedActions == Qt.LinkAction) {
                var p = destArea.mapToGlobal(drag.x, drag.y)
                console.log("move", drag.x, drag.y, p)
                movingShape.endPoint = Qt.point(drag.x, drag.y)
            } else {
                drag.accepted = true
                followItem.x = drag.x - 4
                followItem.y = drag.y - 4
            }
        }

        onDropped: {
            if (drop.supportedActions == Qt.CopyAction) {
                var actorData = {
                    "x": drop.x,
                    "y": drop.y,
                    "name": drop.getDataAsString("name"),
                    "id": drop.getDataAsString("id"),
                    "type": drop.getDataAsString("type"),
                    "form": drop.getDataAsString("form"),
                    "Drag.supportedActions": Qt.MoveAction,
                    "Drag.dragType": Drag.Internal
                }
                actorComponent.createObject(destArea, actorData)
                followItem.active = false
                drop.acceptProposedAction()
                drop.accepted = true
            } else if (drop.supportedActions == Qt.MoveAction) {
                console.log("move action, drop.source - ", drop.source,
                            " drop.source.source - ", drop.source.source)
            } else if (drop.supportedActions == Qt.LinkAction) {
                console.log("link action, drop.source - ", drop.source,
                            " drop.source.source - ", drop.source.source)
            }
        }
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
            strokeColor: "yellow"
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

    Component {
        id: actorComponent

        ActorForm {}
    }
}
