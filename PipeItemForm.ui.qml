import QtQuick 2.0
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import CPipe 1.0

Item {
    id: formRoot
    clip: true
    property alias mouseArea: mouseArea
    property var sourceForm
    property var targetForm
    property CPipe pipe

    property double alpha: 1.0

    property point startPoint
    property point endPoint

    anchors {
        top: sourceForm.y < targetForm.y ? sourceForm.top : targetForm.top
        left: sourceForm.x < targetForm.x ? sourceForm.left : targetForm.left
        bottom: sourceForm.y + sourceForm.height > targetForm.y
                + targetForm.height ? sourceForm.bottom : targetForm.bottom
        right: sourceForm.x + sourceForm.width > targetForm.x
               + targetForm.width ? sourceForm.right : targetForm.right
    }

    Shape {
        anchors.fill: parent
        antialiasing: true
        ShapePath {
            id: path
            strokeColor: "aquamarine"
            strokeWidth: 4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            strokeStyle: ShapePath.SolidLine

            property int joinStyleIndex: 0

            property variant styles: [ShapePath.BevelJoin, ShapePath.MiterJoin, ShapePath.RoundJoin]

            joinStyle: styles[joinStyleIndex]

            startX: startPoint.x
            startY: startPoint.y
            PathLine {
                x: endPoint.x
                y: endPoint.y
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
        }
    }
}
