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
        background: FastBlur {
            opacity: 0.7
            radius: 25
        }
        RowLayout {
            anchors.leftMargin: 4
            anchors.fill: parent

            ComboBox {
                currentIndex: 0
                Layout.fillWidth: true
                id: groupListBox
                model: ListModel {
                    id: groupListModel
                }
            }

            ToolButton {
                id: addGroupButton
                icon.source: "img/ic_add_group"
                onClicked: {
                    addGroupDialog.open()
                }
            }

            ToolButton {
                id: removeGroupButton
                icon.source: "img/ic_delete"
                enabled: groupListBox.currentText != "all"
                onClicked: removeGroupDialog.open()
            }
        }
    }

    footer: ToolBar {
        id: bottomBar
        width: parent.width

        background: FastBlur {
            opacity: 0.7
            radius: 25
        }

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
        anchors.fill: gridView
        acceptedButtons: Qt.RightButton
        onClicked: contextMenu.popup(mouse.x, mouse.y)
    }

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: 8
        focus: true
        model: ListModel {
            ListElement {
                name: "Grey"
                colorCode: "grey"
            }

            ListElement {
                name: "Red"
                colorCode: "red"
            }

            ListElement {
                name: "Blue"
                colorCode: "blue"
            }

            ListElement {
                name: "Green"
                colorCode: "green"
            }
        }
        delegate: Item {
            id: itemRoot
            x: 5
            width: gridView.cellWidth
            height: gridView.cellHeight
            Row {
                id: row1
                spacing: 10
                Rectangle {
                    width: 40
                    height: 40
                    color: colorCode
                }

                Text {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }
            }
            MouseArea {
                drag.target: row1
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        itemMenu.popup(itemRoot, mouse.x, mouse.y)
                    }
                    gridView.currentIndex = index
                }
            }
        }

        highlight: Rectangle {
            border.color: "lightsteelblue"
            border.width: 2
            //            width: listView.width
            color: "transparent"
            radius: 5
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }

    Menu {
        id: addMenu

        MenuItem {
            text: "function"
            onTriggered: {

            }
        }
        MenuItem {
            text: "cmd"
            onTriggered: {

            }
        }
    }

    Menu {
        id: itemMenu

        MenuItem {
            text: qsTr("Delete")
            icon.source: "img/ic_delete"
            onClicked: {

            }
        }
        MenuItem {
            text: qsTr("Edit")
            icon.source: "img/ic_edit"
            onClicked: {

            }
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("Clear All")
            icon.source: "img/ic_clear"
            onClicked: {

            }
        }

        MenuSeparator {}

        Menu {
            title: qsTr("Add...")

            MenuItem {
                text: "Function"
                onTriggered: {

                }
            }
            MenuItem {
                text: "Cmd"
                onTriggered: {

                }
            }
        }
    }

    Dialog {
        id: addGroupDialog
        width: 300
        height: 200
        anchors.centerIn: Overlay.overlay

        title: "Please input group name"
        standardButtons: Dialog.Save | Dialog.Cancel
        parent: Overlay.overlay
        TextField {
            width: parent.width
            id: groupNameText
            selectByMouse: true
        }

        onOpened: groupNameText.text = ""

        onAccepted: {
            if (groupNameText.text.trim().length > 0) {
                var item = {
                    "name": groupNameText.text
                }
                actorModel.addGroupJson(item)
                groupListModel.append(item)
            }
        }
    }

    Dialog {
        id: removeGroupDialog
        width: 400
        height: 150
        anchors.centerIn: Overlay.overlay
        title: "Are you confirm to delete the group?"
        standardButtons: Dialog.Yes | Dialog.No
        parent: Overlay.overlay

        onAccepted: {
            actorModel.removeGroup(groupListBox.currentIndex - 1)
            groupListModel.remove(groupListBox.currentIndex)
        }
    }

    Component.onCompleted: {
        var groupList = actorModel.listGroupJson()
        groupListModel.append({
                                  "name": "all"
                              })
        groupList.forEach(function (group) {
            groupListModel.append(group)
        })
    }
}
