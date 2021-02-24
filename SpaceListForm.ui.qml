import QtQuick 2.12
import QtQuick.Controls 2.13

Frame {
    id: root
    width: 400
    height: 400

    signal workbenchOpenRequested(var space)

    property var currentItem: null
    property alias currentIndex: listView.currentIndex
    property alias rootArea: rootArea
    property alias listView: listView
    property alias itemMenu: itemMenu
    property alias contextMenu: contextMenu

    MouseArea {
        id: rootArea
        anchors.fill: listView
        acceptedButtons: Qt.RightButton
    }

    ListView {
        id: listView
        anchors.fill: parent
        focus: true
        spacing: 8

        footer: Button {
            id: addButton
            width: parent.width
            action: addAction
        }
        footerPositioning: ListView.OverlayFooter
    }

    Menu {
        id: itemMenu
        property int spaceIndex: 0
    }

    Menu {
        id: contextMenu
    }

    property Action saveAction: Action {
        id: saveAction
        text: "Save"
    }

    property Action editAction: Action {
        icon.source: "img/ic_edit"
        text: "Edit"
    }
    property Action removeAction: Action {
        icon.source: "img/ic_delete"
        text: "Remove"
    }
    property Action addAction: Action {
        text: "Add"
        icon.source: "img/ic_add"
    }
}
