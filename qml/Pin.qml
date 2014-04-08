import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Rectangle {
    property var functions: ["GPIO", "I2C", "UART"]
    property var info: ["gpio1_0", "i2c1_cs", "uart0_sck"]
    property string type: "GPIO"
    property string cape: "cape-test"
    property string previewType: ""
    property bool previewEnabled: false
    property string gpioType: "in"
    property int number: 0
    property var colorMap: [["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]
    property alias numberVisible: numberText.visible
    property string description: "Test"
    property bool editable: true
    property var textInput: leftTextInput.visible? leftTextInput: rightTextInput
    property string infoText: {
        var functionIndex = functions.indexOf((previewEnabled?previewType:type))
        if ((functionIndex != -1) && (info.length > functionIndex)) {
            return info[functionIndex]
        }
        else {
            return ""
        }
    }

    signal previewEntered(string type)
    signal previewExited()

    id: main
    width: 100
    height: 62
    color: {
        for (var i = 0; i < colorMap.length; ++i)
        {
            if (colorMap[i][0] === ((previewEnabled && (previewType != ""))?previewType:type))
            {
                return colorMap[i][1]
            }
        }

        return "grey"
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
        visible: !(previewEnabled && (previewType != "")) && ((main.number % 2) == 0)
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
        visible: previewEnabled && ((main.number % 2) == 0)
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
        visible: (!previewEnabled && (previewType != "")) && ((main.number % 2) == 1)
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
        visible: previewEnabled && ((main.number % 2) == 1)
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
