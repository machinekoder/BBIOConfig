import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Rectangle {
    property var functions: ["GPIO", "I2C", "UART"]
    property string type: "GPIO"
    property string previewType: ""
    property bool previewEnabled: false
    property string gpioType: "in"
    property int number: 0
    property var colorMap: [["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]
    property alias numberVisible: numberText.visible
    property string description: "Test"
    property bool editable: true

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
    }

    TextInput {
        id: rightTextInput
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        anchors.leftMargin: parent.width * 0.8
        width: parent.width*6
        horizontalAlignment: TextInput.AlignLeft
        font.pixelSize: parent.width*0.9
        visible: (main.number % 2) == 0
        readOnly: !main.editable

        MouseArea {
            anchors.fill: parent
            cursorShape: main.editable? Qt.IBeamCursor: Qt.ArrowCursor
            enabled: false
        }

        Binding { target: main; property: "description"; value: rightTextInput.text }
        Binding { target: rightTextInput; property: "text"; value: main.description }
    }

    TextInput {
        id: leftTextInput
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.left
        anchors.rightMargin: parent.width * 0.8
        width: parent.width*6
        horizontalAlignment: TextInput.AlignRight
        font.pixelSize: parent.width*0.9
        visible: (main.number % 2) == 1
        readOnly: !main.editable

        MouseArea {
            anchors.fill: parent
            cursorShape: main.editable? Qt.IBeamCursor: Qt.ArrowCursor
            enabled: false
        }

        Binding { target: main; property: "description"; value: leftTextInput.text }
        Binding { target: leftTextInput; property: "text"; value: main.description }
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
