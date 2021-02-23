import QtQuick 2.4

PipeItemForm {
    id: formRoot

    Connections {
        target: sourceForm
        function onXChanged() {
            updatePathPoint()
        }
        function onYChanged() {
            updatePathPoint()
        }
        function onHeightChanged() {
            updatePathPoint()
        }
        function onWidthChanged() {
            updatePathPoint()
        }
    }

    Connections {
        target: targetForm
        function onXChanged() {
            updatePathPoint()
        }
        function onYChanged() {
            updatePathPoint()
        }
        function onHeightChanged() {
            updatePathPoint()
        }
        function onWidthChanged() {
            updatePathPoint()
        }
    }

    function updatePathPoint() {
        startPoint = formRoot.mapFromItem(sourceForm, sourceForm.width / 2,
                                          sourceForm.height / 2)
        endPoint = formRoot.mapFromItem(targetForm, targetForm.width / 2,
                                        targetForm.height / 2)
    }

    mouseArea.onPressed: {
        let x0 = mouse.x
        let y0 = mouse.y
        let a = endPoint.y - startPoint.y
        let b = startPoint.x - endPoint.x
        let c = endPoint.x * startPoint.y - startPoint.x * endPoint.y
        let d = Math.abs(x0 * a + y0 * b + c) / Math.sqrt(a * a + b * b)
        mouse.accepted = d < 6 && x0 >= Math.min(startPoint.x, endPoint.x)
                && x0 <= Math.max(startPoint.x, endPoint.x)
    }

    mouseArea.onClicked: {
        console.log("clicked...")
        //TODO
    }

    Component.onCompleted: {
        updatePathPoint()
    }
}
