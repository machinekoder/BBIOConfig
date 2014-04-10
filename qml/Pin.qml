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
import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Rectangle {
    property string defaultFunction: "GPIO"                                             // function when cape is not loded
    property var    functions: ["GPIO", "I2C", "UART"]                                  // pinmux functions
    property var    info: ["gpio1_0", "gpio1_0", "i2c1_cs", "uart0_sck"]                // info to default function and pinmux functions
    property string type: "GPIO"                                                        // current selected type
    property string overlay: "cape-test"                                                // overlay that is necessary for pinmuxing
    property var    loadedOverlays: ["cape-test", "cape-test2"]                         // currently loaded overlay
    property bool   pinmuxActive: (loadedOverlays.indexOf(overlay) !== -1)              // determines wheter the pinmux is active or not
    property string previewType: ""                                                     // type for preview mode
    property bool   previewEnabled: false                                               // enabled the preview mdoe
    property bool   previewActive:  getPreviewActive()                                  // holds whether the preview is active or not
    property string gpioDirection: "unmodified"                                         // type of the gpio pin (in or out)
    property var    gpioDirections: ["unmodified", "in", "out"]
    property string gpioValue: "unmodified"                                             // startup gpio value
    property var    gpioValues: ["unmodifed", "low", "high"]
    property int    number: 0                                                           // number of the pin
    property var    colorMap: [["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]     // current avtive color map
    property alias  numberVisible: numberText.visible                                   // visibility of the number
    property string description: "Test"                                                 // descriptive text for the pin
    property bool   editable: getEditable()                                             // editability of the pin
    property var    textInput: leftTextInput.visible? leftTextInput: rightTextInput     // currently active text input
    property string infoText: getInfoText()                                             // info text for the pin
    property int    configMode: 0                                                       // active config mode: 0=function, 1=gpio dir, 2=gpio value
    property double uneditableOpacitiy: (configMode == 0)?1.0:0.2

    signal previewEntered(string type)
    signal previewExited()

    id: main
    width: 100
    height: 62
    color: getColor()
    opacity: (editable || previewActive || (previewEnabled && previewType == ""))?1.0:uneditableOpacitiy

    function getEditable() {
        switch (configMode) {
        case 0: return pinmuxActive
        case 1: return (type === "gpio")
        case 2: return ((type === "gpio") && (gpioDirection === "out"))
        default: return false
        }
    }

    function getInfoText() {
        var functionIndex = functions.indexOf((previewActive?previewType:type))
        if (!pinmuxActive && !previewActive)
            return info[0]

        if ((previewActive) && previewType == defaultFunction)
            return info[0]

        if ((functionIndex != -1) && (info.length > (functionIndex+1))) {
            return info[functionIndex+1]
        }
        else {
            return ""
        }
    }

    function getColor() {
        var searchValue

        if (main.configMode == 1) {
            searchValue = main.gpioDirection
        }
        else if (main.configMode == 2) {
            searchValue = main.gpioValue
        }
        else if (main.previewActive) {
            searchValue = main.previewType
        }
        else if (main.pinmuxActive) {
            searchValue = main.type
        }
        else {
            searchValue = main.defaultFunction
        }

        for (var i = 0; i < main.colorMap.length; ++i)
        {
            if (main.colorMap[i][0] === searchValue)
            {
                return main.colorMap[i][1]
            }
        }
        return "grey"
    }

    function getPreviewActive() {

        if ((!previewEnabled) || (previewType == ""))
            return false

        if (previewType === defaultFunction)
            return true

        if (functions.indexOf(previewType) != -1)
            return true;

        return false;
    }

    Text {
        id: numberText
        anchors.fill: parent
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: main.number
        font.bold: true
        font.pixelSize: parent.width*0.6
    }

    ComboBox {
        id: comboBox
        anchors.fill: parent
        model: main.functions
        style: ComboBoxStyle {
            background: Item {}
            label: Item {}
        }
        visible: (main.editable && (main.configMode == 0))

        Binding { target: main; property: "type"; value: comboBox.currentText}
        Binding { target: comboBox; property: "currentText"; value: main.type}

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Tab) || (event.key === Qt.Key_Return)) {
                textInput.forceActiveFocus()
            }
        }
    }

    ComboBox {
        id: comboBox2
        anchors.fill: parent
        model: main.gpioDirections
        style: ComboBoxStyle {
            background: Item {}
            label: Item {}
        }
        visible: (main.editable && (main.configMode == 1))

        Binding { target: main; property: "gpioDirection"; value: comboBox2.currentText}
        Binding { target: comboBox2; property: "currentText"; value: main.gpioDirection}

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Tab) || (event.key === Qt.Key_Return)) {
                textInput.forceActiveFocus()
            }
        }
    }

    ComboBox {
        id: comboBox3
        anchors.fill: parent
        model: main.gpioValues
        style: ComboBoxStyle {
            background: Item {}
            label: Item {}
        }
        visible: (main.editable && (main.configMode == 2))

        Binding { target: main; property: "gpioValue"; value: comboBox3.currentText}
        Binding { target: comboBox3; property: "currentText"; value: main.gpioValue}

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Tab) || (event.key === Qt.Key_Return)) {
                textInput.forceActiveFocus()
            }
        }
    }

    TextInput {
        id: rightTextInput
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        anchors.leftMargin: parent.width * 0.8
        width: parent.width*6
        horizontalAlignment: TextInput.AlignLeft
        font.pixelSize: parent.width*0.9
        visible: !previewActive && ((main.number % 2) == 0)
        readOnly: !main.editable

        MouseArea {
            anchors.fill: parent
            cursorShape: main.editable? Qt.IBeamCursor: Qt.ArrowCursor
            enabled: false
        }

        Binding { target: main; property: "description"; value: rightTextInput.text }
        Binding { target: rightTextInput; property: "text"; value: main.description }

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Return)) {
                var target
                switch (main.configMode) {
                case 0: target = comboBox; break;
                case 1: target = comboBox2; break;
                case 2: target = comboBox3; break;
                }
                target.forceActiveFocus()
            }
        }
    }

    Text {
        id: rightInfoText
        anchors.verticalCenter: rightTextInput.verticalCenter
        anchors.left: rightTextInput.left
        width: rightTextInput.width
        horizontalAlignment: rightTextInput.horizontalAlignment
        font: rightTextInput.font
        visible: previewActive && ((main.number % 2) == 0)
        text: main.infoText
    }

    TextInput {
        id: leftTextInput
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.left
        anchors.rightMargin: parent.width * 0.8
        width: parent.width*6
        horizontalAlignment: TextInput.AlignRight
        font.pixelSize: parent.width*0.9
        visible: !previewActive && ((main.number % 2) == 1)
        readOnly: !main.editable

        MouseArea {
            anchors.fill: parent
            cursorShape: main.editable? Qt.IBeamCursor: Qt.ArrowCursor
            enabled: false
        }

        Binding { target: main; property: "description"; value: leftTextInput.text}
        Binding { target: leftTextInput; property: "text"; value: main.description}

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Return)) {
                var target
                switch (main.configMode) {
                case 0: target = comboBox; break;
                case 1: target = comboBox2; break;
                case 2: target = comboBox3; break;
                }
                target.forceActiveFocus()
            }
        }
    }

    Text {
        id: leftInfoText
        anchors.verticalCenter: leftTextInput.verticalCenter
        anchors.right: leftTextInput.right
        width: leftTextInput.width
        horizontalAlignment: leftTextInput.horizontalAlignment
        font: leftTextInput.font
        visible: previewActive && ((main.number % 2) == 1)
        text: main.infoText
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: main.editable? Qt.PointingHandCursor: Qt.ArrowCursor
        enabled: previewEnabled && (previewType == "")
        hoverEnabled: true
        onHoveredChanged: {
            if (containsMouse)
            {
                previewEntered(main.type)
            }
            else
            {
                previewExited()
            }
        }
    }
}
