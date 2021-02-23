import QtQuick 2.4

SpaceItemForm {
    id: root
    actorFormMap: Object()

    destArea.onEntered: {
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

    destArea.onPositionChanged: {
        if (drag.supportedActions == Qt.LinkAction) {
            var p = destArea.mapToGlobal(drag.x, drag.y)
            movingShape.endPoint = Qt.point(drag.x, drag.y)
        } else {
            drag.accepted = true
            followItem.x = drag.x - 4
            followItem.y = drag.y - 4
        }
    }

    destArea.onDropped: {
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

    Component {
        id: actorComponent

        ActorItem {
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
            onStateChanged: flickable.interactive = actorForm.state != "resizing"
        }
    }

    Component {
        id: pipeComponent
        PipeItem {
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
}
