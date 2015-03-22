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
import QtQuick.Window 2.0
import FileIO 1.0
import "Functions.js" as Functions

Rectangle {
    property var portList: [port8, port9]
    property string currentFile: ""
    property string currentFileName: (currentFile == "") ? "Untitled" : currentFile.substring(currentFile.lastIndexOf("/")+1)
    property var functionColorMap: []
    property var gpioDirectionColorMap: []
    property var gpioValueColorMap: []
    property string documentTitle: qsTr("BeagleBone Universal IO Configurator")
    property bool modified: false

    signal dataChanged()

    function openDocument(fileUrl) {
        currentFile = fileUrl
        Functions.loadPinmux()
        return Functions.loadConfig(currentFile)
    }

    function saveDocument(fileUrl) {
        if (fileUrl !== "")
            currentFile = fileUrl
        return Functions.saveConfig(currentFile)
    }

    function newDocument() {
        currentFile = ""
        Functions.loadPinmux()
    }

    onDataChanged: modified = true

    id: main
    width: 1000
    height: 800
    color: "white"

    Component.onCompleted: {
        loadTimer.running = true
    }

    Timer {
        id: loadTimer

        running: false
        repeat: true
        interval: 10
        onTriggered: {
            // Wait for the ports to get ready
            var ready = true
            for (var i = 0; i < portList.length; ++i)
            {
                if (!portList[i].ready)
                {
                    ready = false
                    break
                }
                portList[i].createTabOrder()
            }

            if (ready)
            {
                main.functionColorMap = Functions.loadColorMap(":/bbioconfig/qml/colormap.txt")
                main.gpioDirectionColorMap = Functions.loadColorMap(":/bbioconfig/qml/colormap1.txt")
                main.gpioValueColorMap = Functions.loadColorMap(":/bbioconfig/qml/colormap2.txt")

                if (main.currentFile != "") // the file was already loaded
                    openDocument(main.currentFile)
                else
                    Functions.loadPinmux()


                loadTimer.running = false
                console.log("loaded")
            }
        }
    }

    File {
        id: configFile
    }

    OverlaySelector {
        id: overlaySelector
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: Screen.logicalPixelDensity * 2
        width: Screen.logicalPixelDensity * 40
        height: Screen.logicalPixelDensity * 40
        title: qsTr("Overlays")

        onOutputChanged: main.dataChanged()
    }

    ConfigModeSelector {
        id: configModeSelector
        anchors.left: parent.left
        anchors.top: overlaySelector.bottom
        anchors.margins: overlaySelector.anchors.margins
        width: overlaySelector.width
        height: Screen.logicalPixelDensity * 30
        title: qsTr("Config Mode")
        input: [qsTr("Pin function"), qsTr("GPIO direction"), qsTr("GPIO value")]
    }

    GroupBox {
        id: settingsGroup
        anchors.left: parent.left
        anchors.top: configModeSelector.bottom
        anchors.margins: overlaySelector.anchors.margins
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
        anchors.margins: Screen.logicalPixelDensity * 2
        width: Screen.pixelDensity * 25
        colorMap: selector.currentColorMap
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
        anchors.margins: parent.height * 0.05
        width: height

        Image {
            anchors.fill: parent
            source: "BBB_shape.png"
            fillMode: Image.PreserveAspectFit
        }

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

            onTextChanged: main.dataChanged()
        }

        Port {
            id: port9

            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width * 0.054
            anchors.topMargin: parent.height * 0.275
            anchors.leftMargin: parent.width * 0.245
            currentColorMap: selector.currentColorMap
            loadedOverlays: overlaySelector.output
            previewType: legend.previewType
            previewOverlay: overlaySelector.hoveredItem
            previewEnabled: (legend.previewType != "") || (overlaySelector.hoveredItem != "")
            configMode: configModeSelector.currentIndex
            portNumber: 9
            displayUneditablePins: displayUneditablePinsCheck.checked

            onDataChanged: main.dataChanged()
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
            anchors.right: parent.right
            width: parent.width * 0.054
            anchors.topMargin: parent.height * 0.275
            anchors.rightMargin: parent.width * 0.245
            currentColorMap: selector.currentColorMap
            loadedOverlays: overlaySelector.output
            previewType: legend.previewType
            previewOverlay: overlaySelector.hoveredItem
            previewEnabled: (legend.previewType != "") || (overlaySelector.hoveredItem != "")
            configMode: configModeSelector.currentIndex
            portNumber: 8
            displayUneditablePins: displayUneditablePinsCheck.checked

            onDataChanged: main.dataChanged()
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
