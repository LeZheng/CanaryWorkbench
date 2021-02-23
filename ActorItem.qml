import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

ActorItemForm {
    id: formRoot

    onActorItemChanged: {
        formRoot.x = actorItem.x
        formRoot.y = actorItem.y
    }

    dragArea.onClicked: {
        if (mouse.button == Qt.RightButton) {
            let slotList = formRoot.actorItem.impl.getSlotList()

            slotList.forEach(function (slot) {
                console.log("slots:", JSON.stringify(slot))
                let act = slotActComponent.createObject(slotMenu, {
                                                            "actorSlot": slot
                                                        })
                slotMenu.addAction(act)
            })
            contextMenu.popup(dragArea, mouse.x, mouse.y)
        }
    }

    closeAction.onTriggered: {
        //TODO delete pipe first
        workspaceModel.removeActor(actorItem.id)
        formRoot.destroy()
    }

    contextMenu.onClosed: {
        let count = slotMenu.count
        for (var i = 0; i < count; i++) {
            slotMenu.takeAction(0)
        }
    }

    destArea.onPositionChanged: {
        if (drag.supportedActions == Qt.LinkAction) {
            var p = destArea.mapToItem(formRoot.parent, drag.x, drag.y)
            drag.accepted = true
            formRoot.dragMoved(p)
        }
    }

    destArea.onDropped: {
        if (drop.supportedActions == Qt.LinkAction) {
            drop.acceptProposedAction()
            drop.accepted = true

            let sActor = actorModel.getActor(drop.getDataAsString("actorId"))
            let signalList = sActor.getSignals()
            let tActor = actorModel.getActor(actorItem.actorId)
            let slotList = tActor.getSlots()

            let dialog = pipeDialogComponent.createObject(formRoot, {
                                                              "sourceId": drop.getDataAsString(
                                                                              "id"),
                                                              "targetId": actorItem.id,
                                                              "sourceName": sActor.name,
                                                              "targetName": tActor.name,
                                                              "signalList": signalList,
                                                              "slotList": slotList
                                                          })
            dialog.open()
        }
    }

    leftFrame.onPositionChanged: {
        if (pressedButtons & Qt.LeftButton) {
            if (formRoot.width - mouse.x >= 100) {
                formRoot.width = formRoot.width - mouse.x
                formRoot.x = formRoot.x + mouse.x
            }
        }
    }

    topFrame.onPositionChanged: {
        if (pressedButtons & Qt.LeftButton) {
            if (formRoot.height - mouse.y >= 100) {
                formRoot.height = formRoot.height - mouse.y
                formRoot.y = formRoot.y + mouse.y
            }
        }
    }

    rightFrame.onPositionChanged: {
        if (pressedButtons & Qt.LeftButton) {
            if (formRoot.width + mouse.x >= 100) {
                formRoot.width = formRoot.width + mouse.x
            }
        }
    }

    bottomFrame.onPositionChanged: {
        if (pressedButtons & Qt.LeftButton) {
            if (formRoot.height + mouse.y >= 100) {
                formRoot.height = formRoot.height + mouse.y
            }
        }
    }

    Component {
        id: pipeDialogComponent
        Dialog {
            id: createPipeDialog
            title: "Create Pipe"
            property var sourceId
            property var targetId
            property var sourceName
            property var targetName
            property var signalList: []
            property var slotList: []
            GridLayout {
                columns: 2

                Label {
                    text: createPipeDialog.sourceName
                }
                ComboBox {
                    id: signalBox
                    Layout.minimumWidth: 200
                    model: createPipeDialog.signalList
                }
                Label {
                    text: createPipeDialog.targetName
                }
                ComboBox {
                    id: slotBox
                    model: createPipeDialog.slotList
                    Layout.minimumWidth: 200
                }
            }

            standardButtons: Dialog.Ok | Dialog.Cancel

            onAccepted: {
                formRoot.pipeDropped(sourceId, targetId, signalBox.currentText,
                                     slotBox.currentText)
            }
        }
    }

    Component {
        id: slotActComponent

        Action {
            property var actorSlot: null
            id: slotAction
            text: actorSlot.name

            onTriggered: {
                if (actorSlot.parameters.length > 0) {
                    let params = actorSlot.parameters.map(function (p) {
                        return JSON.parse(JSON.stringify(p))
                    })
                    let dialog = argDialogComponent.createObject(formRoot, {
                                                                     "argDescList": params
                                                                 })

                    dialog.open()
                    dialog.inputCompleted.connect(function (args) {
                        console.log("args:", args)
                        formRoot.actorItem.impl[actorSlot.name].apply(
                                    null, args ? args : null)
                    })
                } else {
                    formRoot.actorItem.impl[actorSlot.name].apply(null)
                }
            }
        }
    }

    Component {
        id: argDialogComponent

        ArgumentDialog {
            id: argDialog
        }
    }

    Component {
        id: defaultComponent

        Rectangle {
            id: defaultItem
            color: "blue"
            anchors.fill: parent
            anchors.margins: 5

            Text {
                id: actorName
                text: name
            }
        }
    }

    Component.onCompleted: {
        console.log("complete:", actorItem)
        let actor = actorItem.impl
        formRoot.form = actor.form //FIXME first add is null
        formRoot.type = actor.type
        formRoot.name = actor.name
        if (form.length > 0) {
            let actor = Qt.createComponent(form).createObject(formFrame)
        } else {
            let defaultForm = defaultComponent.createObject(formFrame)
        }
    }
}
