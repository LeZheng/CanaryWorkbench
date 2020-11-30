import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: qsTr("Stack")

    background: FastBlur {
        source: Image {
            source: "img/main_bg"
        }

        radius: 63
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            Action {
                text: qsTr("&New...")
            }
            Action {
                text: qsTr("&Open...")
            }
            Action {
                text: qsTr("&Save")
            }
            Action {
                text: qsTr("Save &As...")
            }
            MenuSeparator {}
            Action {
                text: qsTr("&Quit")
            }
        }
        Menu {
            title: qsTr("&Edit")
            Action {
                text: qsTr("Cu&t")
            }
            Action {
                text: qsTr("&Copy")
            }
            Action {
                text: qsTr("&Paste")
            }
        }
        Menu {
            title: qsTr("&Help")
            Action {
                text: qsTr("&About")
            }
        }
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                drawer.open()
            }
        }

        Label {
            text: qsTr("title")
            anchors.centerIn: parent
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.33
        height: window.height

        SystemMenu {
            anchors.fill: parent
        }
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        SpaceListForm {
            id: spaceListForm
            SplitView.preferredWidth: window.width * 0.2

            onWorkbenchOpenRequested: {
                for (var i = 0; i < workbenchTabs.count; i++) {
                    if (workbenchTabs.itemAt(i).text === name) {
                        workbenchTabs.currentIndex = i
                        return
                    }
                }

                var tab = tabComponent.createObject(workbenchTabs, {
                                                        "text": name
                                                    })
                var workbench = workbenchComponent.createObject(
                            workbenchLayouts, {
                                "name": name
                            })
            }
        }

        ColumnLayout {
            clip: true
            SplitView.fillWidth: true

            TabBar {
                id: workbenchTabs
                Layout.fillWidth: true
            }

            StackLayout {
                id: workbenchLayouts
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: workbenchTabs.currentIndex
            }
        }

        WorkBox {
            SplitView.preferredWidth: window.width * 0.2
        }
    }

    Component {
        id: workbenchComponent

        WorkspaceForm {
            id: workbench
        }
    }

    Component {
        id: tabComponent

        TabButton {
            id: tab
            width: 200
        }
    }
}
