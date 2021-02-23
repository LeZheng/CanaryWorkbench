import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Dialog {
    id: argDialog

    property var argDescList: []

    contentHeight: argListView.contentHeight + 16
    contentWidth: 200
    Component {
        id: argComponent

        RowLayout {
            width: 200
            Label {
                text: name
            }

            TextField {
                id: valueText
                placeholderText: type
                Layout.fillWidth: true

                onTextChanged: {
                    argDescList[index].value = valueText.text
                }
            }
        }
    }

    ListModel {
        id: argModel
    }

    contentItem: ListView {
        id: argListView
        model: argModel
        anchors.margins: 8
        delegate: argComponent
    }

    onClosed: argModel.clear()

    standardButtons: Dialog.Ok | Dialog.Cancel
    onAccepted: {
        argDialog.inputCompleted(argDescList.map(function (arg) {
            return arg.value ? arg.value : ""
        }))
    }

    signal inputCompleted(var args)

    Component.onCompleted: {
        argDescList.forEach(function (a) {
            argModel.append(a)
        })
    }
}
