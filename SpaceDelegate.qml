import QtQuick 2.4

SpaceDelegateForm {
    width: parent.width

    signal itemMenuRequested
    signal itemClicked
    signal itemLongClicked
    signal itemDoubleClicked

    mouseArea.onClicked: {
        if (mouse.button === Qt.RightButton) {
            itemMenuRequested()
        } else {
            itemClicked()
        }
        mouse.accepted = true
    }

    mouseArea.onPressAndHold: {
        if (mouse.button === Qt.LeftButton) {
            itemLongClicked()
        }
    }

    mouseArea.onDoubleClicked: itemDoubleClicked()
}
