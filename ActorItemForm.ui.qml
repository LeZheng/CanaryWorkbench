import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14
import QtQuick.Layouts 1.14
import CActorItem 1.0

Rectangle {
    id: formRoot
    z: 5
    border.width: 1
    border.color: "black"
    color: "white"
    radius: 3
    clip: false

    signal dragMoved(point p)
    signal pipeDropped(string inputId, string outputId, string signalName, string slotName)
    property int frameWidth: 2
    property CActorItem actorItem
    property alias destArea: destArea
    property alias dragArea: dragArea
    property alias closeAction: closeAction
    property alias contextMenu: contextMenu
    property alias formFrame: formFrame

    property alias topFrame: topFrame
    property alias bottomFrame: bottomFrame
    property alias leftFrame: leftFrame
    property alias rightFrame: rightFrame

    property string form
    property string name
    property string id
    property string type

    height: 100
    width: 100

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

    states: [
        State {
            name: "resizing"
        },
        State {
            name: "idle"
        }
    ]

    MouseArea {
        id: dragArea
        z: 6
        hoverEnabled: true
        anchors.fill: parent
        drag.target: formRoot
        acceptedButtons: Qt.RightButton | Qt.LeftButton
    }

    Frame {
        id: formFrame
        anchors {
            fill: parent
            topMargin: 30
            leftMargin: 5
            rightMargin: 5
            bottomMargin: 5
        }
    }

    MouseArea {
        id: leftFrame
        width: frameWidth
        z: 8
        cursorShape: Qt.SizeHorCursor
        anchors {
            topMargin: frameWidth
            bottomMargin: frameWidth
            top: formRoot.top
            bottom: formRoot.bottom
            left: formRoot.left
        }

        onPressed: formRoot.state = "resizing"
        onReleased: formRoot.state = "idle"
    }

    MouseArea {
        id: topFrame
        height: frameWidth
        z: 8
        cursorShape: Qt.SizeVerCursor
        anchors {
            leftMargin: frameWidth
            rightMargin: frameWidth
            top: formRoot.top
            right: formRoot.right
            left: formRoot.left
        }

        onPressed: formRoot.state = "resizing"
        onReleased: formRoot.state = "idle"
    }

    MouseArea {
        id: rightFrame
        width: frameWidth
        z: 8
        cursorShape: Qt.SizeHorCursor
        anchors {
            topMargin: frameWidth
            bottomMargin: frameWidth
            top: formRoot.top
            bottom: formRoot.bottom
            right: formRoot.right
        }

        onPressed: formRoot.state = "resizing"
        onReleased: formRoot.state = "idle"
    }

    MouseArea {
        id: bottomFrame
        width: frameWidth
        z: 8
        cursorShape: Qt.SizeVerCursor
        anchors {
            leftMargin: frameWidth
            rightMargin: frameWidth
            left: formRoot.left
            bottom: formRoot.bottom
            right: formRoot.right
        }

        onPressed: formRoot.state = "resizing"
        onReleased: formRoot.state = "idle"
    }

    Text {
        id: actorName
        text: name
        anchors.margins: 3
        anchors.top: parent.top
        anchors.left: parent.left
    }

    ToolButton {
        id: actorCloseBtn
        width: 30
        height: 30
        z: 7
        anchors {
            top: parent.top
            right: parent.right
        }

        action: closeAction
    }

    Rectangle {
        id: rect1
        border.width: 1
        border.color: "black"
        width: 8
        height: 8
        radius: 5
        z: 8
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        Drag.active: m1.drag.active
        Drag.supportedActions: Qt.LinkAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "id": actorItem.id,
            "actorId": actorItem.actorId
        }

        MouseArea {
            id: m1
            z: 3
            anchors.fill: parent
            drag.target: rect1
        }
    }

    Rectangle {
        id: rect2
        border.width: 1
        border.color: "black"
        width: 8
        height: 8
        radius: 5
        z: 8
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Drag.active: m2.drag.active
        Drag.supportedActions: Qt.LinkAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "id": actorItem.id,
            "actorId": actorItem.actorId
        }

        MouseArea {
            id: m2
            z: 3
            anchors.fill: parent
            drag.target: rect2
        }
    }

    Rectangle {
        id: rect3
        border.width: 1
        border.color: "black"
        width: 8
        height: 8
        radius: 5
        z: 8
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Drag.active: m3.drag.active
        Drag.supportedActions: Qt.LinkAction
        Drag.dragType: Drag.Automatic
        Drag.mimeData: {
            "id": actorItem.id,
            "actorId": actorItem.actorId
        }

        MouseArea {
            id: m3
            z: 3
            anchors.fill: parent
            drag.target: rect3
        }
    }

    DropArea {
        id: destArea
        anchors.fill: parent
    }

    Menu {
        id: contextMenu

        Menu {
            id: slotMenu
            title: "Action..."
        }

        MenuSeparator {}

        MenuItem {
            action: closeAction
        }
    }

    Action {
        id: closeAction
        text: "close"
        icon.source: "img/ic_close"
    }
}
