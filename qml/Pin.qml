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
    property string gpioDirection: "in"                                                 // type of the gpio pin (in or out)
    property string gpioValue: "hi"                                                     // startup gpio value
    property int    number: 0                                                           // number of the pin
    property var    colorMap: [["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]     // current avtive color map
    property alias  numberVisible: numberText.visible                                   // visibility of the number
    property string description: "Test"                                                 // descriptive text for the pin
    property bool   editable: pinmuxActive                                              // editability of the pin
    property var    textInput: leftTextInput.visible? leftTextInput: rightTextInput     // currently active text input
    property string infoText: getInfoText()                                             // info text for the pin

    signal previewEntered(string type)
    signal previewExited()

    id: main
    width: 100
    height: 62
    color: getColor()
    opacity: (editable || previewActive || (previewEnabled && previewType == ""))?1.0:0.8

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
        for (var i = 0; i < colorMap.length; ++i)
        {
            if (colorMap[i][0] === ((previewActive)?previewType:(pinmuxActive?type:defaultFunction)))
            {
                return colorMap[i][1]
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
        model: functions
        style: ComboBoxStyle {
            background: Item {}
            label: Item {}
        }
        visible: main.editable

        Binding { target: main; property: "type"; value: comboBox.currentText }
        Binding { target: comboBox; property: "currentText"; value: main.type }

        Keys.onMenuPressed: {
            textInput.forceActiveFocus()
        }
        Keys.onTabPressed: {
            textInput.forceActiveFocus()
        }
        Keys.onReturnPressed: {
            textInput.forceActiveFocus()
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

        Keys.onMenuPressed: {
            comboBox.forceActiveFocus()
        }
        Keys.onReturnPressed: {
            comboBox.forceActiveFocus()
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

        Keys.onMenuPressed: {
            comboBox.forceActiveFocus()
        }
        Keys.onReturnPressed: {
            comboBox.forceActiveFocus()
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
