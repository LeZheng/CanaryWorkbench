import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14
import QtQuick.Layouts 1.14
import ActorItem 1.0
import QtQuick.Dialogs 1.2

Rectangle {
    id: formRoot

    border.width: 1
    border.color: "black"
    color: "white"
    radius: 3
    clip: false

    signal dragMoved(point p)
    signal pipeDropped(string inputId, string outputId, string signalName, string slotName)
    property int frameWidth: 2
    property ActorItem actorItem

    property string form
    property string name
    property string id
    property string type

    height: 100
    width: 100

    onActorItemChanged: {
        formRoot.x = actorItem.x
        formRoot.y = actorItem.y
    }

    Binding {
        target: actorItem
        property: "x"
        value: formRoot.x
    }
    Binding {
        target: actorItem
        property: "y"
        value: formRoot.y
    }

    Drag.active: dragArea.drag.active
    Drag.supportedActions: Qt.MoveAction
    Drag.dragType: Drag.Automatic
    Drag.mimeData: {
        "id": id,
        "name": name,
        "type": type,
        "form": form
    }

    states: [
        State {
            name: "resizing"
        },
        State {
            name: "idle"
        }
    ]

    MouseArea {
        id: dragArea
        z: 1
        hoverEnabled: true
        anchors.fill: parent
        drag.target: formRoot
        acceptedButtons: Qt.RightButton | Qt.LeftButton

        onClicked: {
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
    }

    Frame {
        id: formFrame
        anchors {
            fill: parent
            topMargin: 30
            leftMargin: 5
            rightMargin: 5
            bottomMargin: 5
        }
    }

    MouseArea {
        id: leftFrame
        width: frameWidth
        z: 3
        cursorShape: Qt.SizeHorCursor
        anchors {
            topMargin: frameWidth
            bottomMargin: frameWidth
            top: formRoot.top
            bottom: formRoot.bottom
            left: formRoot.left
        }

        onPositionChanged: {
            if (pressedButtons & Qt.LeftButton) {
                if (formRoot.width - mouse.x >= 100) {
                    formRoot.width = formRoot.width - mouse.x
                    formRoot.x = formRoot.x + mouse.x
                }
            }
        }
        onPressed: formRoot.state = "resizing"
        onReleased: formRoot.state = "idle"
    }

    MouseArea {
        id: topFrame
        height: frameWidth
        z: 3
        cursorShape: Qt.SizeVerCursor
        anchors {
            leftMargin: frameWidth
            rightMargin: frameWidth
            top: formRoot.top
            right: formRoot.right
            left: formRoot.left
        }

        onPositionChanged: {
            if (pressedButtons & Qt.LeftButton) {
                if (formRoot.height - mouse.y >= 100) {
                    formRoot.height = formRoot.height - mouse.y
                    formRoot.y = formRoot.y + mouse.y
                }
            }
        }
        onPressed: formRoot.state = "resizing"
        onReleased: formRoot.state = "idle"
    }

    MouseArea {
        id: rightFrame
        width: frameWidth
        z: 3
        cursorShape: Qt.SizeHorCursor
        anchors {
            topMargin: frameWidth
            bottomMargin: frameWidth
            top: formRoot.top
            bottom: formRoot.bottom
            right: formRoot.right
        }

        onPositionChanged: {
            if (pressedButtons & Qt.LeftButton) {
                if (formRoot.width + mouse.x >= 100) {
                    formRoot.width = formRoot.width + mouse.x
                }
            }
        }
        onPressed: formRoot.state = "resizing"
        onReleased: formRoot.state = "idle"
    }

    MouseArea {
        id: bottomFrame
        width: frameWidth
        z: 3
        cursorShape: Qt.SizeVerCursor
        anchors {
            leftMargin: frameWidth
            rightMargin: frameWidth
            left: formRoot.left
            bottom: formRoot.bottom
            right: formRoot.right
        }

        onPositionChanged: {
            if (pressedButtons & Qt.LeftButton) {
                if (formRoot.height + mouse.y >= 100) {
                    formRoot.height = formRoot.height + mouse.y
                }
            }
        }
        onPressed: formRoot.state = "resizing"
        onReleased: formRoot.state = "idle"
    }

    Text {
        id: actorName
        text: name
        anchors.margins: 3
        anchors.top: parent.top
        anchors.left: parent.left
    }

    ToolButton {
        id: actorCloseBtn
        width: 30
        height: 30
        z: 2
        anchors {
            top: parent.top
            right: parent.right
        }

        action: closeAction
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
        let actor = actorModel.getActor(actorItem.actorId)
        formRoot.form = actor.form
        formRoot.type = actor.type
        formRoot.name = actor.name
        if (form.length > 0) {
            let actor = Qt.createComponent(form).createObject(formFrame)
        } else {
            let defaultForm = defaultComponent.createObject(formFrame)
        }
    }

    Rectangle {
        id: rect1
        border.width: 1
        border.color: "black"
        width: 8
        height: 8
        radius: 5
        z: 3
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        Drag.active: m1.drag.active
        Drag.supportedActions: Qt.LinkAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "id": actorItem.id,
            "actorId": actorItem.actorId
        }

        MouseArea {
            id: m1
            z: 3
            anchors.fill: parent
            drag.target: rect1
        }
    }

    Rectangle {
        id: rect2
        border.width: 1
        border.color: "black"
        width: 8
        height: 8
        radius: 5
        z: 3
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Drag.active: m2.drag.active
        Drag.supportedActions: Qt.LinkAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "id": actorItem.id,
            "actorId": actorItem.actorId
        }

        MouseArea {
            id: m2
            z: 3
            anchors.fill: parent
            drag.target: rect2
        }
    }

    Rectangle {
        id: rect3
        border.width: 1
        border.color: "black"
        width: 8
        height: 8
        radius: 5
        z: 3
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Drag.active: m3.drag.active
        Drag.supportedActions: Qt.LinkAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "id": actorItem.id,
            "actorId": actorItem.actorId
        }

        MouseArea {
            id: m3
            z: 3
            anchors.fill: parent
            drag.target: rect3
        }
    }

    DropArea {
        id: destArea
        anchors.fill: parent

        onPositionChanged: {
            if (drag.supportedActions == Qt.LinkAction) {
                var p = destArea.mapToItem(formRoot.parent, drag.x, drag.y)
                drag.accepted = true
                formRoot.dragMoved(p)
            }
        }

        onDropped: {
            if (drop.supportedActions == Qt.LinkAction) {
                drop.acceptProposedAction()
                drop.accepted = true

                let sActor = actorModel.getActor(drop.getDataAsString(
                                                     "actorId"))
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

    Menu {
        id: contextMenu

        Menu {
            id: slotMenu
            title: "Action..."
        }

        MenuSeparator {}

        MenuItem {
            action: closeAction
        }

        onClosed: {
            let count = slotMenu.count
            for (var i = 0; i < count; i++) {
                slotMenu.takeAction(0)
            }
        }
    }

    Action {
        id: closeAction
        text: "close"
        icon.source: "img/ic_close"

        onTriggered: {
            //TODO
            formRoot.destroy()
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
                        formRoot.actorItem.impl[actorSlot.name].apply(null,
                                                                      args)
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
}
