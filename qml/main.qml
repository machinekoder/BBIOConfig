/*****************************************************************************
    Copyright (c) 2014 Alexander Rössler <mail.aroessler@gmail.com>

    This file is part of BBPinConfig.

    BBIOConfig is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BBIOConfig is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BBIOConfig.  If not, see <http://www.gnu.org/licenses/>.

 *****************************************************************************/
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import FileIO 1.0
import "Functions.js" as Functions

ApplicationWindow {
    property var portList: [port8, port9]
    property string currentFile: ""
    property var functionColorMap: []
    property var gpioDirectionColorMap: []
    property var gpioValueColorMap: []
    property string documentTitle: qsTr("BeagleBone Universal IO Configurator")

    id: main
    visible: true
    width: 1000
    height: 800
    title: qsTr("BB Universal IO Configurator (BBIOConfig)")

    Component.onCompleted: {
        functionColorMap = Functions.loadColorMap(":/qml/colormap.txt")
        gpioDirectionColorMap = Functions.loadColorMap(":/qml/colormap1.txt")
        gpioValueColorMap = Functions.loadColorMap(":/qml/colormap2.txt")
        Functions.loadPinmux()

        for (var i = 0; i < portList.length; ++i)
        {
            portList[i].createTabOrder()
        }
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&New")
                iconName: "document-new"

                onTriggered: {
                    currentFile = ""
                    Functions.loadPinmux()
                }

                action: Action {
                    shortcut: "Ctrl+N"
                    tooltip: qsTr("Create a new config")
                }
            }

            MenuItem {
                text: qsTr("&Open...")
                iconName: "document-open"

                onTriggered: fileOpenDialog.visible = true

                action: Action {
                    shortcut: "Ctrl+O"
                    tooltip: qsTr("Open a config file..")
                }
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("&Save")
                iconName: "document-save"

                onTriggered: currentFile == "" ? fileSaveDialog.visible = true : Functions.saveConfig(currentFile)

                action: Action {
                    shortcut: "Ctrl+S"
                    tooltip: qsTr("Saves the config file")
                }
            }

            MenuItem {
                text: qsTr("Save &As..")
                iconName: "document-save-as"

                onTriggered: fileSaveDialog.visible = true

                action: Action {
                    shortcut: "Ctrl+Shift+S"
                    tooltip: qsTr("Saves the config file as..")
                }
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("E&xit")
                iconName: "application-exit"

                onTriggered: Qt.quit()

                action: Action {
                    shortcut: "Ctrl+Q"
                    tooltip: qsTr("Exit")
                }
            }
        }
        Menu {
            title: qsTr("&Help")
            MenuItem {
                text: qsTr("&Online Documentation")
                iconName: "help-contents"

                onTriggered: Qt.openUrlExternally("https://github.com/strahlex/BBIOConfig/wiki")
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("&About")
                iconName: "help-about"

                onTriggered: aboutDialog.visible = true
            }
        }
    }

    MessageDialog {
        id: aboutDialog
        title: qsTr("About BBIOConfig")
        text: qsTr("<h2>BeagleBone Universal IO Configurator<br>" +
                   "BBIOConfig</h2> <br>" +
                   "Copyright (C) 2014 by Alexander Rössler (<a href='mailto:mail.aroessler@gmail.com'>mail.aroessler@gmail.com</a>)<br><br>" +
                   "BBIOConfig is free software: you can redistribute it and/or modify<br>" +
                   "it under the terms of the GNU General Public License as published by<br>" +
                   "the Free Software Foundation, either version 3 of the License, or<br>" +
                   "(at your option) any later version.<br><br>" +

                   "BBIOConfig is distributed in the hope that it will be useful,<br>" +
                   "but WITHOUT ANY WARRANTY; without even the implied warranty of<br>" +
                   "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the<br>" +
                   "GNU General Public License for more details.<br><br>" +

                   "You should have received a copy of the GNU General Public License<br>" +
                   "along with BBIOConfig.  If not, see <http://www.gnu.org/licenses/>.<br>")
    }

    File {
        id: configFile
    }

    Rectangle {
        color: "white"
        anchors.fill: parent

        OverlaySelector {
            id: overlaySelector
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: selector.width * 0.02
            anchors.topMargin: selector.width * 0.02
            width: selector.width * 0.2
            height: selector.height * 0.14
            title: qsTr("Overlays")
        }

        ConfigModeSelector {
            id: configModeSelector
            anchors.left: parent.left
            anchors.top: overlaySelector.bottom
            anchors.leftMargin: overlaySelector.anchors.leftMargin
            anchors.topMargin: overlaySelector.anchors.topMargin
            width: overlaySelector.width
            height: selector.height * 0.14
            title: qsTr("Config Mode")
            input: [qsTr("Pin function"), qsTr("GPIO direction"), qsTr("GPIO value")]
        }

        GroupBox {
            id: settingsGroup
            anchors.left: parent.left
            anchors.top: configModeSelector.bottom
            anchors.leftMargin: overlaySelector.anchors.leftMargin
            anchors.topMargin: overlaySelector.anchors.topMargin
            width: configModeSelector.width
            title: qsTr("Display")

            CheckBox {
                id: displayUneditablePinsCheck
                text: qsTr("Uneditable Pins")
                checked: true
            }
        }

        Legend {
            id: legend
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: selector.width * 0.02
            anchors.bottomMargin: selector.height * 0.05
            width: selector.width * 0.16
            colorMap: selector.currentColorMap
        }

        Text {
            id: fileNameText
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: currentFile
        }

        FileDialog {
            id: fileOpenDialog
            title: qsTr("Please choose a io file")
            selectExisting: true
            nameFilters: [ "BB Universion IO file (*.bbio)", "All files (*)" ]
            onAccepted: {
                currentFile = fileUrl
                Functions.loadPinmux()
                Functions.loadConfig(fileUrl)
            }
            onRejected: {
                console.log("Canceled")
            }
        }

        FileDialog {
            id: fileSaveDialog
            title: qsTr("Please choose a io file")
            selectExisting: false
            nameFilters: [ "BB Universion IO file (*.bbio)", "All files (*)" ]
            onAccepted: {
                currentFile = fileUrl
                Functions.saveConfig(fileUrl)
            }
            onRejected: {
                console.log("Canceled")
            }
        }

        Item {
            property var currentColorMap: {
                switch (configModeSelector.currentIndex) {
                case 0: return functionColorMap
                case 1: return gpioDirectionColorMap
                case 2: return gpioValueColorMap
                default: return functionColorMap
                }
            }

            id: selector
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 10
            width: height

            Image {
                anchors.fill: parent
                source: "BBB_shape.svg"
                fillMode: Image.PreserveAspectFit

                TextInput {
                    id: titleText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: parent.height * 0.01
                    width: parent.width
                    horizontalAlignment: TextInput.AlignHCenter
                    font.pixelSize: parent.width * 0.03
                    font.bold: true
                    text: main.documentTitle
                    selectByMouse: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        enabled: false
                    }

                    Binding { target: titleText; property: "text"; value: main.documentTitle }
                    Binding { target: main; property: "documentTitle"; value: titleText.text }
                }

                Port {
                    id: port9

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    width: parent.width * 0.054
                    anchors.topMargin: parent.height * 0.265
                    anchors.bottomMargin: parent.height * 0.18
                    anchors.leftMargin: parent.width * 0.245
                    currentColorMap: selector.currentColorMap
                    loadedOverlays: overlaySelector.output
                    previewType: legend.previewType
                    previewEnabled: legend.previewEnabled
                    configMode: configModeSelector.currentIndex
                    portNumber: 9
                    displayUneditablePins: displayUneditablePinsCheck.checked
                }

                Text {
                    text: "P9"
                    color: "grey"
                    anchors.top: port9.bottom
                    anchors.topMargin: parent.height*0.01
                    anchors.horizontalCenter: port9.horizontalCenter
                    anchors.horizontalCenterOffset: parent.width * 0.03
                    font.pixelSize: parent.width * 0.04
                }

                Port {
                    id: port8

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: parent.width * 0.054
                    anchors.topMargin: parent.height * 0.265
                    anchors.bottomMargin: parent.height * 0.18
                    anchors.rightMargin: parent.width * 0.245
                    currentColorMap: selector.currentColorMap
                    loadedOverlays: overlaySelector.output
                    previewType: legend.previewType
                    previewEnabled: legend.previewEnabled
                    configMode: configModeSelector.currentIndex
                    portNumber: 8
                    displayUneditablePins: displayUneditablePinsCheck.checked
                }

                Text {
                    text: "P8"
                    color: "grey"
                    anchors.top: port8.bottom
                    anchors.topMargin: parent.height*0.01
                    anchors.horizontalCenter: port8.horizontalCenter
                    anchors.horizontalCenterOffset: -parent.width * 0.03
                    font.pixelSize: parent.width * 0.04
                }
            }
        }
    }
}
