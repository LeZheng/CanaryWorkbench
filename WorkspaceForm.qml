import QtQuick 2.4

import QtQuick 2.4
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import Workspace 1.0
import ActorItem 1.0

Pane {
    id: root
    clip: true

    property string colorKey
    property string name
    property Workspace workspace
    property var actorFormMap: Object()

    width: 400
    height: 400

    background: FastBlur {
        opacity: 0.7
        radius: 25
    }

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

            onEntered: {
                console.log("enter:", drag.source.x, drag.source.y)
                if (drag.supportedActions == Qt.LinkAction) {
                    movingShape.visible = true
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
                    movingShape.endPoint = Qt.point(drag.x, drag.y)
                } else {
                    drag.accepted = true
                    followItem.x = drag.x - 4
                    followItem.y = drag.y - 4
                }
            }

            onDropped: {
                if (drop.supportedActions == Qt.CopyAction) {
                    let time = new Date().getUTCMilliseconds()
                    var actorData = {
                        "x": drop.x,
                        "y": drop.y,
                        "name": drop.getDataAsString("name"),
                        "id": drop.getDataAsString("id") + time,
                        "actorId": drop.getDataAsString("id"),
                        "type": drop.getDataAsString("type"),
                        "form": drop.getDataAsString("form")
                    }
                    var actor = workspaceModel.addActor(workspace, actorData)
                    addActor(actor)

                    followItem.active = false
                    drop.acceptProposedAction()
                    drop.accepted = true
                } else if (drop.supportedActions == Qt.MoveAction) {
                    console.log("move action, drop.source - ", drop.source,
                                " drop.source.source - ", drop.source.source)
                } else if (drop.supportedActions == Qt.LinkAction) {
                    movingShape.visible = false
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
    }

    function addActor(actor) {
        var form = actorComponent.createObject(destArea, {
                                                   "actorItem": actor
                                               })
        root.actorFormMap[actor.id] = form
        form.Component.onDestruction.connect(function () {
            root.actorFormMap[actor.id] = null //TODO delete key
        })
    }

    function addPipe(pipe) {
        pipeComponent.createObject(destArea, {
                                       "pipe": pipe,
                                       "sourceForm": root.actorFormMap[pipe.inputId],
                                       "targetForm": root.actorFormMap[pipe.outputId]
                                   })
    }

    Component {
        id: actorComponent

        ActorForm {
            id: actorForm
            Drag.supportedActions: Qt.MoveAction
            Drag.dragType: Drag.Internal
            onDragMoved: {
                movingShape.endPoint = p
            }
            onPipeDropped: {
                movingShape.visible = false
                var pipeJson = {
                    "outputId": outputId,
                    "inputId": inputId,
                    "signalName": signalName,
                    "slotName": slotName
                }
                var pipe = workspaceModel.addPipe(workspace, pipeJson)
                console.log("add pipe:", pipe, JSON.stringify(pipeJson))
                addPipe(pipe)
            }
            onStateChanged: {
                flickable.interactive = actorForm.state != "resizing"
            }
        }
    }

    Component {
        id: pipeComponent
        PipeForm {
            id: pipeForm
        }
    }

    Component.onCompleted: {
        workspace = workspaceModel.get(name)
        for (var i = 0; i < workspace.actorList.length; i++) {
            addActor(workspace.actorList[i])
        }
        for (var i = 0; i < workspace.pipeList.length; i++) {
            addPipe(workspace.pipeList[i])
        }
    }
}
