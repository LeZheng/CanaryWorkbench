import QtQuick 2.0

import QtQuick 2.4
import QtQuick.Controls 2.13

Frame {
    id: root
    width: 400
    height: 400

    signal workbenchOpenRequested(string name)

    property var currentItem: null
    property alias currentIndex: listView.currentIndex
    property alias count: spaceListModel.count

    MouseArea {
        anchors.fill: listView
        acceptedButtons: Qt.RightButton
        onClicked: {
            contextMenu.popup(mouse.x, mouse.y)
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        focus: true
        model: ListModel {
            id: spaceListModel
        }
        delegate: Item {
            id: itemRoot
            x: 5
            width: parent.width
            height: 40

            Text {
                text: name
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
                color: "white"
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        itemMenu.spaceIndex = index
                        itemMenu.popup(itemRoot)
                    } else {
                        listView.currentIndex = index
                        currentItem = spaceListModel.get(index)
                    }
                    mouse.accepted = true
                }

                onPressAndHold: {
                    if (mouse.button == Qt.LeftButton) {
                        itemMenu.spaceIndex = index
                        itemMenu.popup(itemRoot)
                    }
                }

                onDoubleClicked: root.workbenchOpenRequested(name)
            }
        }

        highlight: Rectangle {
            border.color: "lightsteelblue"
            border.width: 2
            color: "transparent"
            radius: 5
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
        footer: Button {
            id: addButton
            text: "add new"
            width: parent.width
            onClicked: addAction.trigger(addButton)
        }
        footerPositioning: ListView.OverlayFooter
    }

    Dialog {
        id: addSpaceDialog
        width: 300
        height: 200
        anchors.centerIn: Overlay.overlay

        title: "Please enter workspace name"
        standardButtons: Dialog.Save | Dialog.Cancel
        parent: Overlay.overlay
        TextField {
            width: parent.width
            id: wsNameText
            selectByMouse: true
        }

        onOpened: {
            wsNameText.text = ""
        }

        onAccepted: {
            if (wsNameText.text.length > 0) {
                var item = {
                    "name": wsNameText.text
                }
                workspaceModel.addJson(item)
                spaceListModel.append(item)
            }
        }
    }

    Menu {
        id: itemMenu
        property int spaceIndex: 0
        Component.onCompleted: {
            itemMenu.addAction(removeAction)
            itemMenu.addAction(editAction)
            itemMenu.addAction(saveAction)
        }
    }

    Menu {
        id: contextMenu
        Component.onCompleted: {
            contextMenu.addAction(addAction)
        }
    }

    Action {
        id: saveAction
        text: "Save"
        onTriggered: {
            workspaceModel.save(currentItem)
        }
    }

    Action {
        id: editAction
        icon.source: "img/ic_edit"
        text: "Edit"
    }
    Action {
        id: removeAction
        icon.source: "img/ic_delete"
        text: "Remove"
        onTriggered: {
            let data = spaceListModel.data(itemMenu.spaceIndex)
            workspaceModel.remove(data.name)
            spaceListModel.remove(itemMenu.spaceIndex)
        }
    }
    Action {
        id: addAction
        text: "Add"
        icon.source: "img/ic_add"
        onTriggered: {
            wsNameText.text = ""
            addSpaceDialog.open()
        }
    }

    Component.onCompleted: {
        var list = workspaceModel.listJson()
        spaceListModel.clear()

        //        var x = workspaceModel.list()
        //        console.log("loaded:", x)
        list.forEach(function (w) {
            spaceListModel.append(w)
        })
    }
}
