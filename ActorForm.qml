import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Item {
    id: formRoot

    height: 100
    width: 100

    property string form
    property string name
    property string id
    property string type

    property bool entered: false

    Drag.active: dragArea.drag.active
    Drag.supportedActions: Qt.MoveAction
    Drag.dragType: Drag.Automatic
    Drag.mimeData: {
        "id": id,
        "name": name,
        "type": type,
        "form": form
    }

    FastBlur {
        anchors.fill: formRoot
        radius: 32
    }

    MouseArea {
        id: dragArea
        z: 1
        hoverEnabled: true
        anchors.fill: parent
        drag.target: formRoot

        onEntered: formRoot.entered = true

        onExited: formRoot.entered = false
    }

    Frame {
        id: formFrame
        anchors {
            fill: parent
            topMargin: 30
            leftMargin: 10
            rightMargin: 10
            bottomMargin: 10
        }
    }

    Text {
        id: actorName
        text: name
        color: "white"
        visible: formRoot.entered
        anchors.top: parent.top
        anchors.left: parent.left
    }

    ToolButton {
        id: actorCloseBtn
        width: 30
        height: 30
        z: 2
        visible: formRoot.entered
        anchors {
            top: parent.top
            right: parent.right
        }

        icon.source: "img/ic_close"

        onClicked: {
            //TODO
            formRoot.destroy()
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
            let actor = Qt.createComponent(form).createObject(formFrame)
        } else {
            let defaultForm = defaultComponent.createObject(formFrame)
        }
    }

    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        visible: formRoot.entered
        anchors.left: parent.left
        anchors.top: parent.top
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        visible: formRoot.entered
        anchors.left: parent.left
        anchors.bottom: parent.bottom
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        visible: formRoot.entered
        anchors.right: parent.right
        anchors.top: parent.top
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        visible: formRoot.entered
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        visible: formRoot.entered
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        visible: formRoot.entered
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        visible: formRoot.entered
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }
    Rectangle {
        border.width: 1
        border.color: "white"
        width: 5
        height: 5
        visible: formRoot.entered
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
