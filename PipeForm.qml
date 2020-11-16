import QtQuick 2.0
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import Pipe 1.0

Item {
    id: formRoot
    clip: true
    property var sourceForm
    property var targetForm
    property Pipe pipe

    property double alpha: 1.0

    property point startPoint: formRoot.mapFromItem(sourceForm,
                                                    sourceForm.width / 2,
                                                    sourceForm.height / 2)
    property point endPoint: formRoot.mapFromItem(targetForm,
                                                  targetForm.width / 2,
                                                  targetForm.height / 2)

    function updatePathPoint() {
        startPoint = formRoot.mapFromItem(sourceForm, sourceForm.width / 2,
                                          sourceForm.height / 2)
        endPoint = formRoot.mapFromItem(targetForm, targetForm.width / 2,
                                        targetForm.height / 2)
    }

    onSourceFormChanged: {
        sourceForm.onXChanged.connect(updatePathPoint)
        sourceForm.onYChanged.connect(updatePathPoint)
        sourceForm.onHeightChanged.connect(updatePathPoint)
        sourceForm.onWidthChanged.connect(updatePathPoint)
    }
    onTargetFormChanged: {
        targetForm.onXChanged.connect(updatePathPoint)
        targetForm.onYChanged.connect(updatePathPoint)
        targetForm.onHeightChanged.connect(updatePathPoint)
        targetForm.onWidthChanged.connect(updatePathPoint)
    }

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
        ShapePath {
            id: path
            strokeColor: "white"
            strokeWidth: 6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            strokeStyle: ShapePath.DashLine

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
            anchors.fill: parent
            onPressed: {
                let x0 = mouse.x
                let y0 = mouse.y
                let a = endPoint.y - startPoint.y
                let b = startPoint.x - endPoint.x
                let c = endPoint.x * startPoint.y - startPoint.x * endPoint.y
                let d = Math.abs(x0 * a + y0 * b + c) / Math.sqrt(a * a + b * b)
                mouse.accepted = d < 6 && x0 >= Math.min(startPoint.x,
                                                         endPoint.x)
                        && x0 <= Math.max(startPoint.x, endPoint.x)
            }

            onClicked: {
                console.log("clicked...")
                //TODO
            }
        }
    }

    Component.onCompleted: {
        console.log("complete => ", sourceForm)
        updatePathPoint()
    }
}
