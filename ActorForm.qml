import QtQuick 2.12
import QtQuick.Controls 2.12

Pane {
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
        drag.target: parent

        onReleased: {

            //            if (parent.Drag.supportedActions === Qt.CopyAction) {
            //                dragItem.x = 0
            //                dragItem.y = 0
            //            }
        }
    }

    Component {
        id: defaultComponent

        Rectangle {
            id: defaultItem
            color: "blue"
            anchors.fill: parent

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
            //            let actor = actorComponent.createObject(formRoot)
        } else {
            let defaultForm = defaultComponent.createObject(formRoot)
        }
    }
}
