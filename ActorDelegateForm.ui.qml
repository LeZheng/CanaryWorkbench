import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

Item {
    id: itemRoot
    anchors.margins: 5
    anchors.left: parent.left
    anchors.right: parent.right
    height: 50

    property alias itemBackground: bgRect
    property alias mouseArea: mouseArea

    Drag.active: mouseArea.drag.active
    Drag.supportedActions: Qt.CopyAction
    Drag.dragType: Drag.Automatic
    Drag.mimeData: {
        "id": id,
        "name": name,
        "type": type,
        "form": form
    }
    Glow {
        anchors.fill: itemFrame
        radius: 8
        samples: 17
        color: "powderblue"
        source: bgRect
        opacity: itemFrame.hovered ? 1 : 0
    }
    Frame {
        id: itemFrame
        anchors.fill: parent
        anchors.margins: 2
        hoverEnabled: true

        background: Rectangle {
            id: bgRect
            border.width: 1
            border.color: "gray"

            radius: 3
            color: itemFrame.hovered ? "powderblue" : "transparent"
        }

        Text {
            text: name
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
        }
    }

    MouseArea {
        property int prevX: 0
        property int prevY: 0

        id: mouseArea
        drag.target: itemRoot
        drag.threshold: 5
        anchors.fill: itemRoot
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }
}
