import QtQuick 2.0
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import Pipe 1.0

Rectangle {
    id: formRoot
    property var sourceForm
    property var targetForm
    property Pipe pipe

    property double alpha: 1.0

    //    width: Math.abs(sourceForm.x - targetForm.x)
    //    height: Math.abs(sourceForm.y - targetForm.y)

    //    x: Math.min(sourceForm.x, targetForm.x)
    //    y: Math.min(sourceForm.y, targetForm.y)
    color: "white"

    Shape {
        anchors.fill: parent
        ShapePath {
            strokeColor: "white"
            strokeWidth: 16
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            strokeStyle: ShapePath.DashLine

            property int joinStyleIndex: 0

            property variant styles: [ShapePath.BevelJoin, ShapePath.MiterJoin, ShapePath.RoundJoin]

            joinStyle: styles[joinStyleIndex]

            startX: 30 //TODO
            startY: 30
            PathLine {
                x: formRoot.width
                y: formRoot.height
            }
        }
    }

    Component.onCompleted: {
        console.log("complete => ", sourceForm)
    }
}
