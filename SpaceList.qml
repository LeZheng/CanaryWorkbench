import QtQuick 2.12
import QtQuick.Controls 2.12

SpaceListForm {
    id: root

    rootArea.onClicked: contextMenu.popup(mouse.x, mouse.y)

    addAction.onTriggered: asdComponent.createObject(root).open()
    removeAction.onTriggered: {
        let data = spaceListModel.get(itemMenu.spaceIndex)
        workspaceModel.remove(data.id)
        spaceListModel.remove(itemMenu.spaceIndex)
    }
    saveAction.onTriggered: workspaceModel.save(currentItem)

    listView.model: ListModel {
        id: spaceListModel
    }

    listView.delegate: SpaceDelegate {
        onItemMenuRequested: {
            itemMenu.spaceIndex = index
            itemMenu.popup(itemRoot)
        }

        onItemClicked: {
            listView.currentIndex = index
            currentItem = spaceListModel.get(index)
        }

        onItemLongClicked: {
            itemMenu.spaceIndex = index
            itemMenu.popup(itemRoot)
        }

        onItemDoubleClicked: root.workbenchOpenRequested(
                                 spaceListModel.get(index))
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
                    item = workspaceModel.addSpace(item)
                    spaceListModel.append(item)
                }
            }
        }
    }

    Component.onCompleted: {
        var list = workspaceModel.getSpaceList()
        spaceListModel.clear()
        list.forEach(function (w) {
            spaceListModel.append(w)
        })

        itemMenu.addAction(removeAction)
        itemMenu.addAction(editAction)
        itemMenu.addAction(saveAction)

        contextMenu.addAction(addAction)
    }
}
