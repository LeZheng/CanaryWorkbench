import QtQuick 2.12
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import CActor 1.0

Page {
    id: root
    width: 400
    height: 400

    background: null

    property alias actorSetView: actorSetView
    property alias rootArea: rootArea
    property alias groupListBox: groupListBox
    property alias addGroupButton: addGroupButton
    property alias removeGroupButton: removeGroupButton
    property Action addAction: Action {}
    property Action deleteAction: Action {}
    property Action editAction: Action {}
    property Action clearAction: Action {}
    property Action addCmdAction: Action {
        text: "Cmd"
    }

    property Action addFunctionAction: Action {
        text: "function"
    }

    property Action deleteActorAction: Action {
        text: qsTr("Delete")
        icon.source: "img/ic_delete"
    }

    property Action editActorAction: Action {
        text: qsTr("Edit")
        icon.source: "img/ic_edit"
    }

    property Action clearAllAction: Action {
        text: qsTr("Clear All")
        icon.source: "img/ic_clear"
    }

    header: ToolBar {
        id: topBar
        width: parent.width
        RowLayout {
            anchors.leftMargin: 4
            anchors.fill: parent

            ComboBox {
                textRole: "name"
                currentIndex: 0
                Layout.fillWidth: true
                id: groupListBox
                model: groupListModel
            }

            ToolButton {
                id: addGroupButton
                icon.source: "img/ic_add_group"
            }

            ToolButton {
                id: removeGroupButton
                icon.source: "img/ic_delete"
                enabled: groupListBox.currentText != "default"
            }
        }
    }

    footer: ToolBar {
        id: bottomBar
        width: parent.width

        RowLayout {
            height: parent.height

            ToolButton {
                id: addButton
                icon.source: "img/ic_add"
                action: addAction
            }
            ToolButton {
                id: deleteButton
                icon.source: "img/ic_delete"
                action: deleteAction
            }
            ToolButton {
                id: editButton
                icon.source: "img/ic_edit"
                action: editAction
            }
            ToolButton {
                id: clearButton
                icon.source: "img/ic_clear"
                action: clearAction
            }
        }
    }

    MouseArea {
        id: rootArea
        anchors.fill: actorSetView
        acceptedButtons: Qt.RightButton
    }

    ListView {
        id: actorSetView
        anchors.fill: parent
        anchors.margins: 4
        spacing: 5
        focus: true
    }

    ToolTip {
        id: tip
        delay: 500
        visible: false
        timeout: 1000
    }
}
