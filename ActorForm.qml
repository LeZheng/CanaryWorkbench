import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: formRoot

    height: 100
    width: 100

    property string form
    property string name
    property string id
    property string type

    Drag.active: dragArea.drag.active
    Drag.supportedActions: Qt.MoveAction
    Drag.dragType: Drag.Automatic
    Drag.mimeData: {
        "id": id,
        "name": name,
        "type": type,
        "form": form
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: formRoot

        onReleased: {

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
        console.log("complete:", form)
        if (form.length > 0) {
            let actor = Qt.createComponent(form).createObject(formRoot)
        } else {
            let defaultForm = defaultComponent.createObject(formRoot)
        }
    }

    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        anchors.left: parent.left
        anchors.top: parent.top
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        anchors.left: parent.left
        anchors.bottom: parent.bottom
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        anchors.right: parent.right
        anchors.top: parent.top
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
