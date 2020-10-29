import QtQuick 2.0
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12

Rectangle {
    id: formRoot
    property var sourceForm
    property var targetForm
    property point movedPoint: Qt.point(0, 20)

    property double alpha: 1.0

    width: Math.abs(formRoot.x - movedPoint.x)
    height: Math.abs(formRoot.y - movedPoint.y)

    color: "white"

    Shape {
        anchors.fill: parent
        ShapePath {
            strokeColor: "black"
            strokeWidth: 16
            fillColor: "red"
            capStyle: ShapePath.RoundCap
            strokeStyle: ShapePath.DashLine

            property int joinStyleIndex: 0

            property variant styles: [ShapePath.BevelJoin, ShapePath.MiterJoin, ShapePath.RoundJoin]

            joinStyle: styles[joinStyleIndex]

            startX: 30
            startY: 30
            PathLine {
                x: formRoot.width
                y: formRoot.height
            }
            PathLine {
                x: 30
                y: formRoot.height
            }
        }
    }
    state: "connecting"
    states: [
        State {
            name: "connected"
            PropertyChanges {
                target: formRoot
                alpha: 1.0
            }
        },
        State {
            name: "connecting"
            PropertyChanges {
                target: formRoot
                alpha: 0.5
            }
        }
    ]

    Component.onCompleted: {
        console.log("complete => ", sourceForm)
    }
}
