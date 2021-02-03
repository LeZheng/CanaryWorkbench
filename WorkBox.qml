import QtQuick 2.4
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

Page {
    id: root
    width: 400
    height: 400

    background: null

    header: ToolBar {
        id: topBar
        width: parent.width
        RowLayout {
            anchors.leftMargin: 4
            anchors.fill: parent

            ComboBox {
                textRole: "name"
                currentIndex: 0
                Layout.fillWidth: true
                id: groupListBox
                model: ListModel {
                    id: groupListModel
                }

                onCurrentIndexChanged: loadActor()
            }

            ToolButton {
                id: addGroupButton
                icon.source: "img/ic_add_group"
                onClicked: agdComponent.createObject(root).open()
            }

            ToolButton {
                id: removeGroupButton
                icon.source: "img/ic_delete"
                enabled: groupListBox.currentText != "default"
                onClicked: rgdComponent.createObject(root).open()
            }
        }
    }

    footer: ToolBar {
        id: bottomBar
        width: parent.width

        RowLayout {
            height: parent.height

            ToolButton {
                id: addButton
                icon.source: "img/ic_add"
                onClicked: addMenu.popup(addGroupButton)
            }
            ToolButton {
                id: deleteButton
                icon.source: "img/ic_delete"
                onClicked: {

                }
            }
            ToolButton {
                id: editButton
                icon.source: "img/ic_edit"
                onClicked: {

                }
            }
            ToolButton {
                id: clearButton
                icon.source: "img/ic_clear"
                onClicked: {

                }
            }
        }
    }

    MouseArea {
        anchors.fill: actorSetView
        acceptedButtons: Qt.RightButton
        onClicked: contextMenu.popup(mouse.x, mouse.y)
        //        onPressAndHold: contextMenu.popup(mouse.x, mouse.y)TODO
    }

    ListView {
        id: actorSetView
        anchors.fill: parent
        anchors.margins: 4
        spacing: 5
        focus: true
        model: ListModel {
            id: actorListModel
        }
        delegate: Item {
            id: itemRoot
            anchors.margins: 5
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            Drag.active: mouseArea.drag.active
            Drag.supportedActions: Qt.CopyAction
            Drag.dragType: Drag.Automatic
            Drag.mimeData: {
                "id": id,
                "name"//FIXME is null
                : name,
                "type": type,
                "form": form
            }
            Glow {
                anchors.fill: itemFrame
                radius: 8
                samples: 17
                color: "powderblue"
                source: bgRect
                opacity: itemFrame.hovered ? 1 : 0
            }
            Frame {
                id: itemFrame
                anchors.fill: parent
                anchors.margins: 2
                hoverEnabled: true

                background: Rectangle {
                    id: bgRect
                    border.width: 1
                    border.color: "gray"

                    radius: 3
                    color: itemFrame.hovered ? "powderblue" : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                Text {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }
            }

            MouseArea {
                property int prevX: 0
                property int prevY: 0

                id: mouseArea
                drag.target: itemRoot
                drag.threshold: 5
                anchors.fill: itemRoot
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: {
                    prevX = itemRoot.x
                    prevY = itemRoot.y
                }

                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        itemMenu.popup(itemRoot, mouse.x, mouse.y)
                    }
                    actorSetView.currentIndex = index
                    mouse.accepted = true
                }
                onReleased: {
                    if (parent.Drag.supportedActions === Qt.CopyAction) {
                        itemRoot.x = prevX
                        itemRoot.y = prevY
                    }
                }
                onPressAndHold: {
                    if (mouse.button == Qt.LeftButton) {
                        itemMenu.popup(itemRoot, mouse.x, mouse.y)
                    }
                }
            }
        }
    }

    ToolTip {
        id: tip
        delay: 500
        visible: false
        timeout: 1000
    }

    Action {
        id: addCmdAction
        text: "Cmd"
        onTriggered: acdComponent.createObject(root).open()
    }

    Action {
        id: addFunctionAction
        text: "function"
    }

    Action {
        id: deleteActorAction
        text: qsTr("Delete")
        icon.source: "img/ic_delete"
        onTriggered: {
            let actorId = actorListModel.get(actorSetView.currentIndex).id
            actorModel.removeActor(actorId)
            actorListModel.remove(actorSetView.currentIndex)
        }
    }

    Action {
        id: editActorAction
        text: qsTr("Edit")
        icon.source: "img/ic_edit"
    }

    Action {
        id: clearAllAction
        text: qsTr("Clear All")
        icon.source: "img/ic_clear"
        onTriggered: {
            let groupId = groupListModel.get(groupListBox.currentIndex).id
            actorModel.removeActors(groupId)
            actorListModel.clear()
        }
    }

    Menu {
        id: addMenu

        MenuItem {
            action: addFunctionAction
        }
        MenuItem {
            action: addCmdAction
        }
    }

    Menu {
        id: itemMenu

        MenuItem {
            action: deleteActorAction
        }
        MenuItem {
            action: editActorAction
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            action: clearAllAction
        }

        MenuSeparator {}

        Menu {
            title: qsTr("Add...")

            MenuItem {
                action: addFunctionAction
            }
            MenuItem {
                action: addCmdAction
            }
        }
    }

    Component {
        id: agdComponent
        Dialog {
            id: addGroupDialog
            width: 300
            height: 200
            anchors.centerIn: Overlay.overlay

            title: qsTr("Please input group name")
            standardButtons: Dialog.Save | Dialog.Cancel
            parent: Overlay.overlay
            TextField {
                width: parent.width
                id: groupNameText
                selectByMouse: true
                focus: true
            }

            onAccepted: {
                if (groupNameText.text.trim().length > 0) {
                    var item = {
                        "name": groupNameText.text
                    }
                    item = actorModel.addGroupJson(item)
                    groupListModel.append(item)
                }
            }
        }
    }

    Component {
        id: rgdComponent
        Dialog {
            id: removeGroupDialog
            width: 400
            height: 150
            anchors.centerIn: Overlay.overlay
            title: qsTr("Are you confirm to delete the group?")
            standardButtons: Dialog.Yes | Dialog.No
            parent: Overlay.overlay

            onAccepted: {
                let index = groupListBox.currentIndex
                let g = groupListModel.get(index)
                actorModel.removeGroup(g.id)
                groupListModel.remove(index)
                groupListBox.currentIndex = index - 1
            }
        }
    }

    Component {
        id: acdComponent
        Dialog {
            id: addCmdDialog
            width: 400
            anchors.centerIn: Overlay.overlay

            title: "Please input group name"
            standardButtons: Dialog.Save | Dialog.Cancel
            parent: Overlay.overlay

            GridLayout {
                anchors.fill: parent
                columns: 2
                Label {
                    text: "Name:"
                }
                TextField {
                    id: cmdNameField
                    Layout.fillWidth: true
                    selectByMouse: true
                }
                Label {
                    text: "Command:"
                }
                TextField {
                    id: cmdTextField
                    Layout.fillWidth: true
                    selectByMouse: true
                }
                Label {
                    text: "Description:"
                }
                TextField {
                    id: cmdDescField
                    Layout.fillWidth: true
                    selectByMouse: true
                }
            }

            onAccepted: {
                let actor = {
                    "name": cmdNameField.text,
                    "data": cmdTextField.text,
                    "groupId": groupListModel.get(groupListBox.currentIndex).id,
                    "description": cmdDescField.text,
                    "type": "cmd",
                    "form": "CmdActor.qml"
                }

                actorModel.addActor(actor)
                actorListModel.append(actor)
            }
        }
    }

    Component.onCompleted: {
        var groupList = actorModel.listGroupJson()
        groupListModel.append({
                                  "name": "default",
                                  "id": "0"
                              })
        groupList.forEach(function (group) {
            groupListModel.append(group)
        })

        loadActor()
    }

    function loadActor() {
        let actorList = actorModel.getGroupActors(
                groupListModel.get(groupListBox.currentIndex).id)
        actorListModel.clear()
        actorList.forEach(function (actor) {
            actorListModel.append(actor)
        })
    }
}
