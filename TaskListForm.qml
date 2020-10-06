import QtQuick 2.0

import QtQuick 2.4
import QtQuick.Controls 2.13

Frame {
    id: root
    width: 400
    height: 400

    property var currentItem: null

    ListView {
        id: listView
        anchors.fill: parent
        focus: true
        model: ListModel {
            id: spaceListModel
        }
        delegate: Item {
            x: 5
            width: parent.width
            height: 40
            Row {
                id: row1
                spacing: 10
                Rectangle {
                    width: 40
                    height: 40
                }

                Text {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                    color: "white"
                }
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        itemMenu.spaceIndex = index
                        itemMenu.popup(row1)
                    } else {
                        listView.currentIndex = index
                    }
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
        //        highlightFollowsCurrentItem: false
        footer: Button {
            id: addButton
            text: "add new"
            width: parent.width
            onClicked: addAction.trigger(addButton)
        }
        footerPositioning: ListView.OverlayFooter

        //        MouseArea {
        //            anchors.fill: parent
        //            acceptedButtons: Qt.RightButton
        //            onClicked: {
        //                contextMenu.spaceObj = null
        //                contextMenu.popup(mouse.x, mouse.y)
        //            }
        //        }
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
        }
    }

    Action {
        id: editAction
        text: "Edit"
    }
    Action {
        id: removeAction
        text: "Remove"
        onTriggered: {
            workspaceModel.remove(itemMenu.spaceIndex)
            spaceListModel.remove(itemMenu.spaceIndex)
        }
    }
    Action {
        id: addAction
        text: "Add"
        onTriggered: {
            wsNameText.text = ""
            addSpaceDialog.open()
        }
    }

    Component.onCompleted: {
        var list = workspaceModel.listJson()
        spaceListModel.clear()
        list.forEach(function (w) {
            spaceListModel.append(w)
        })
    }
}
