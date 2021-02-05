import QtQuick 2.12

import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import Workspace 1.0
import ActorItem 1.0

Pane {
    id: root
    clip: true

    property string colorKey
    property string id
    property Workspace workspace
    property var actorFormMap: Object()

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

    function addActor(actor) {
        var form = actorComponent.createObject(destArea, {
                                                   "actorItem": actor
                                               })
        root.actorFormMap[actor.id] = form
        form.Component.onDestruction.connect(function () {
            root.actorFormMap[actor.id] = null
        })
    }

    function addPipe(pipe) {
        let source = root.actorFormMap[pipe.inputId]
        let target = root.actorFormMap[pipe.outputId]
        var pipeForm = pipeComponent.createObject(destArea, {
                                                      "pipe": pipe,
                                                      "sourceForm": source,
                                                      "targetForm": target
                                                  })
        let desFun = function () {
            if (pipeForm)
                pipeForm.destroy()
        }
        target.Component.onDestruction.connect(desFun)
        source.Component.onDestruction.connect(desFun)
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
        workspace = workspaceModel.get(id)
        let actorList = workspaceModel.getActorList(workspace.id)
        for (var i = 0; i < actorList.length; i++) {
            addActor(actorList[i])
        }
        let pipeList = workspaceModel.getPipeList(workspace.id)
        for (var i = 0; i < pipeList.length; i++) {
            addPipe(pipeList[i])
        }
        console.log("workspaceForm complete:", workspace.id,
                    JSON.stringify(actorList), pipeList)
    }
}
