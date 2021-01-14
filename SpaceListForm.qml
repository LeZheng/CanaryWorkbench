import QtQuick 2.12
import QtQuick.Controls 2.13

Frame {
    id: root
    width: 400
    height: 400

    signal workbenchOpenRequested(var space)

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
        spacing: 8
        delegate: Frame {
            id: itemRoot
            x: 5
            width: parent.width
            height: 64

            Image {
                id: spaceIcon
                width: 48
                height: 48
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 4
                source: "img/ic_def_space"
            }

            Text {
                anchors.top: spaceIcon.top
                anchors.left: spaceIcon.right
                anchors.right: parent.right
                anchors.margins: 8
                text: name
                font.weight: Font.Light
                font.bold: true
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

                onDoubleClicked: root.workbenchOpenRequested(
                                     spaceListModel.get(index))
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

    Component {
        id: asdComponent
        Dialog {
            id: addSpaceDialog
            width: 300
            height: 200
            anchors.centerIn: Overlay.overlay

            title: qsTr("Please enter workspace name")
            standardButtons: Dialog.Save | Dialog.Cancel
            parent: Overlay.overlay
            TextField {
                width: parent.width
                id: wsNameText
                selectByMouse: true
            }

            onAccepted: {
                if (wsNameText.text.length > 0) {
                    var item = {
                        "name": wsNameText.text
                    }
                    item = workspaceModel.addJson(item)
                    spaceListModel.append(item)
                }
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
            let data = spaceListModel.get(itemMenu.spaceIndex)
            workspaceModel.remove(data.id)
            spaceListModel.remove(itemMenu.spaceIndex)
        }
    }
    Action {
        id: addAction
        text: "Add"
        icon.source: "img/ic_add"
        onTriggered: asdComponent.createObject(root).open()
    }

    Component.onCompleted: {
        var list = workspaceModel.listJson()
        spaceListModel.clear()
        list.forEach(function (w) {
            spaceListModel.append(w)
        })
    }
}
