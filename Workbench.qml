import QtQuick 2.4

import QtQuick 2.4
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Pane {
    id: root

    property string colorKey
    property string name

    width: 400
    height: 400

    background: FastBlur {
        opacity: 0.7
        radius: 25
    }

    DropArea {
        id: destArea
        anchors.fill: parent
        z: -1

        onEntered: {
            drag.accepted = true
            followItem.source = drag.getDataAsString("form")
            followItem.active = true
        }

        onPositionChanged: {
            drag.accepted = true
            followItem.x = drag.x - 4
            followItem.y = drag.y - 4
        }

        onDropped: {
            if (drop.supportedActions == Qt.CopyAction) {
                var actorData = {
                    "x": drop.x,
                    "y": drop.y,
                    "name": drop.getDataAsString("name"),
                    "id": drop.getDataAsString("id"),
                    "type": drop.getDataAsString("type"),
                    "form": drop.getDataAsString("form"),
                    "Drag.supportedActions": Qt.MoveAction,
                    "Drag.dragType": Drag.Internal
                }
                actorComponent.createObject(destArea, actorData)
                followItem.active = false
            } else if (drop.supportedActions == Qt.MoveAction) {
                console.log("move action, drop.source - ", drop.source,
                            " drop.source.source - ", drop.source.source)
            }
            drop.acceptProposedAction()
            drop.accepted = true
        }
        Loader {
            active: false
            id: followItem
            opacity: 0.4
        }
    }

    Component {
        id: actorComponent

        ActorForm {}
    }
}
