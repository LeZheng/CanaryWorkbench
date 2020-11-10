import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import ActorItem 1.0

Item {
    id: formRoot

    signal dragMoved(point p)
    signal pipeDroped(string inputId, string outputId)

    property ActorItem actorItem

    property string form
    property string name
    property string id
    property string type

    property bool entered: false

    height: 100
    width: 100
    x: actorItem.x
    y: actorItem.y

    Binding {
        target: actorItem
        property: "x"
        value: formRoot.x
    }
    Binding {
        target: actorItem
        property: "y"
        value: formRoot.y
    }

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
        console.log("complete:", name, form, actorItem)
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
            "id": actorItem.id
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
            console.log("actor enter:", drag.source)
            if (drag.supportedActions == Qt.LinkAction) {
                formRoot.entered = true
                //                drag.accepted = true
            }
        }

        onExited: formRoot.entered = false

        onPositionChanged: {
            if (drag.supportedActions == Qt.LinkAction) {
                var p = destArea.mapToItem(formRoot.parent, drag.x, drag.y)
                drag.accepted = true
                formRoot.dragMoved(p)
            }
        }

        onDropped: {
            console.log("actor drop")
            if (drop.supportedActions == Qt.LinkAction) {
                drop.acceptProposedAction()
                drop.accepted = true
                formRoot.pipeDroped(drop.getDataAsString("id"), actorItem.id)
            }
        }
    }
}
