import QtQuick 2.4
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

//import QtQuick.Dialogs 1.2
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
                Layout.fillWidth: true
                id: groupListBox
                model: ListModel {
                    id: groupListModel
                    ListElement {
                        text: "user"
                    }
                    ListElement {
                        text: "system"
                    }
                }
            }

            ToolButton {
                id: addGroupButton
                icon.source: "img/ic_add_group"
                onClicked: {
                    addGroupDialog.open()
                }
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
                onClicked: {
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

        onOpened: {
            groupNameText.text = ""
        }

        onAccepted: {
            console.log("accepted...")
        }

        onRejected: {
            console.log("rejected...")
        }
    }
}
