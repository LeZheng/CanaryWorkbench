import QtQuick 2.12
import QtQuick.Controls 2.12

Frame {
    id: itemRoot
    x: 5
    height: 64
    width: 200

    property alias mouseArea: mouseArea

    Image {
        id: spaceIcon
        width: 48
        height: 48
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 4
        source: "img/ic_def_space"
    }

    Text {
        anchors.top: spaceIcon.top
        anchors.left: spaceIcon.right
        anchors.right: parent.right
        anchors.margins: 8
        text: name
        font.weight: Font.Light
        font.bold: true
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
    }
}
