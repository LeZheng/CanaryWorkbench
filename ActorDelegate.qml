import QtQuick 2.4

ActorDelegateForm {
    id: itemRoot

    signal itemMenuRequested(var item, int x, int y)

    Behavior on itemBackground.color {
        ColorAnimation {
            duration: 200
        }
    }

    mouseArea.onPressed: {
        mouseArea.prevX = itemRoot.x
        mouseArea.prevY = itemRoot.y
    }

    mouseArea.onReleased: {
        if (itemRoot.Drag.supportedActions === Qt.CopyAction) {
            itemRoot.x = mouseArea.prevX
            itemRoot.y = mouseArea.prevY
        }
    }

    mouseArea.onPressAndHold: {
        if (mouse.button === Qt.LeftButton) {
            itemMenuRequested(itemRoot, mouse.x, mouse.y)
        }
    }

    mouseArea.onClicked: {
        if (mouse.button === Qt.RightButton) {
            itemMenuRequested(itemRoot, mouse.x, mouse.y)
        }
        mouse.accepted = true
    }
}
