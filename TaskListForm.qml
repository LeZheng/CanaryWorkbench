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
            width: parent.width
            height: 40
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
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = index
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
            text: "add new"
            width: parent.width
            onClicked: addSpaceDialog.open()
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
            console.log("accepted...")
        }

        onRejected: {
            console.log("rejected...")
        }
    }
}
