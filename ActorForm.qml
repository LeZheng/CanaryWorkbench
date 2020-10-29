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

    Pane {
        anchors.fill: formRoot
        visible: formRoot.entered
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
        id: rect1
        border.width: 1
        border.color: "red"
        width: parent.width
        height: 5
        z: 3
        visible: formRoot.entered
        anchors.bottom: parent.bottom

        Drag.active: m1.drag.active
        Drag.supportedActions: Qt.LinkAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "id": id
        }

        MouseArea {
            id: m1
            z: 3
            hoverEnabled: true
            anchors.fill: parent
            drag.target: rect1
        }
    }

    DropArea {
        id: destArea
        anchors.fill: parent

        onEntered: {
            console.log("actor enter:", drag.source.x, drag.source.y)
            if (drag.supportedActions == Qt.LinkAction) {

                drag.accepted = true
            }
        }

        onPositionChanged: {
            if (drag.supportedActions == Qt.LinkAction) {
                console.log("actor move", drag.x, drag.y)
                drag.accepted = true
            }
        }

        onDropped: {
            console.log("actor drop")
            if (drop.supportedActions == Qt.LinkAction) {

                drop.acceptProposedAction()
                drop.accepted = true
            }
        }
    }
}
