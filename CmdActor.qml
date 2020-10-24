import QtQuick 2.0

Rectangle {
    id: root
    anchors.fill: parent
    anchors.margins: 5
    color: "red"

    property string name: ""
    //    property string id: ""
    property string type: "cmd"
    property string form: "CmdActor.qml"
}
