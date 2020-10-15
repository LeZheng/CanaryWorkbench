import QtQuick 2.0

Rectangle {
    id: root
    width: 100
    height: 100
    color: "red"

    property string name: ""
    property string id: ""
    property string type: "cmd"
    property string form: "CmdActor.qml"

    Drag.active: dragArea.drag.active
    Drag.supportedActions: Qt.CopyAction
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
        drag.target: parent

        onReleased: {
            if (parent.Drag.supportedActions === Qt.CopyAction) {
                dragItem.x = 0
                dragItem.y = 0
            }
        }
    }
}
