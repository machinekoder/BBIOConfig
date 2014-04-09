import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.0
import FileIO 1.0

ApplicationWindow {
    property var portList: [port8, port9]
    property string currentFile: ""

    visible: true
    width: 1000
    height: 800
    title: qsTr("BBB Pin Configurator")

    Component.onCompleted: {
        selector.currentColorMap = loadColorMap()
        loadPinmux()

        for (var i = 0; i < portList.length; ++i)
        {
            portList[i].createTabOrder()
        }
    }

    function loadPinmux()
    {
        var functions = []
        var capes = []

        configFile.url = ":/qml/pinmux.txt"
        configFile.load()

        if (configFile.error == true)
        {
            console.log("file error")
            return
        }

        // first set all pins to reserved
        for (var j = 0; j < portList.length; ++j)
        {
            for (var i = 0; i < portList[j].pinList.length; ++i)
            {
                var pin = portList[j].pinList[i]
                pin.functions = ["reserved"]
                pin.info = ["reserved"]
                pin.type = "reserved"
                //pin.editable = false
                pin.description = ""
                pin.overlay = ""
            }
        }

        var lines = configFile.data.split("\n")             // split it into seperate lines
        for (var i = 0; i < lines.length; ++i)
        {
            var line = lines[i]
            if ((line.length === 0) || (line[0] === "#"))   // skip empty and comment lines
                continue;

            var lineData = line.split("=")                  // split the line into a left and right side
            lineData[1] = lineData[1].replace("\"","")      // remove quote marks from the right side
            lineData[1] = lineData[1].replace("\"","")
            var functionsData = lineData[1].split(" ")
            var pinmuxData = lineData[0].split("_")         // split the left side into port, pin and type

            var port = parseInt(pinmuxData[0].substr(1),10) // Port, P<n>
            var pin = parseInt(pinmuxData[1],10)            // Pin <n>
            var type = pinmuxData[2]                        // Type: PINMUX, INFO, CAPE

            for (var j = 0; j < functionsData.length; ++j)  // convert the right side into a list of strings
            {
                var func = functionsData[j]

                switch(type) {
                case "PINMUX":
                    if ((functions.indexOf(func) == -1) && (func !== ""))          // this has no use yet
                    {
                        functions.push(func)
                    }
                    break;
                case "CAPE":
                    if ((capes.indexOf(func) == -1) && (func !== ""))          // this has no use yet
                    {
                        capes.push(func)
                    }
                    break;
                default:
                }
            }

            if ((port === 8) || (port === 9))               // BB has only P8 and P9
            {
                if (pin <= portList[port-8].pinList.length) // BB has 46 pins per port
                {
                    var targetPin = portList[port-8].pinList[pin-1]
                    switch(type) {
                    case "PINMUX":
                        targetPin.functions = functionsData
                        targetPin.type = functionsData[0]
                        break;
                    case "PIN":
                        targetPin.defaultFunction = functionsData[0]
                        break;
                    case "INFO":
                        targetPin.info = functionsData
                        break;
                    case "CAPE":
                        targetPin.overlay = functionsData[0]
                        break;
                    default:
                    }

                }
            }
        }
        console.log(functions)
        overlaySelector.input = capes
    }

    function loadConfig(fileName)
    {
        configFile.url = fileName
        configFile.load()

        if (configFile.error == true)
        {
            console.log("file error")
            return
        }

        var lines = configFile.data.split("\n");

        if (lines.length === 0)
            return

        var overlays = []
        overlaySelector.clearSelection()    // clear selected overlays

        for (var i = 0; i < lines.length; ++i)
        {
            var line = lines[i]

            if ((line.length === 0) || (line[0] === "#")) // skip empty and comment lines
                continue;

            var lineDataRaw = line.split(" ")
            var lineData = []
            for (var j = 0; j < lineDataRaw.length; ++j)
            {
                var lineDataRawLine = lineDataRaw[j]
                if (lineDataRawLine.length > 0)
                {
                    lineData.push(lineDataRawLine.replace("#",""))
                }
            }

            if (lineData.length === 0)
                continue

            var overlayCheckText = lineData[0].toLowerCase()
            switch (overlayCheckText) {
            case "overlay":
            case "ov":
            case "cape":
                overlays.push(lineData[1])
                continue;
            default:
            }

            var pinmuxData = lineData[0].split("_")

            var port = parseInt(pinmuxData[0].substr(1),10)
            var pin = parseInt(pinmuxData[1],10)

            if ((port === 8) || (port === 9))
            {
                if (pin <= portList[port-8].pinList.length)
                {
                    var targetPin = portList[port-8].pinList[pin-1]
                    targetPin.type = lineData[1]
                    if (lineData.length > 2)
                    {
                        targetPin.description = lineData[2]
                        for (var j = 3; j < lineData.length; ++j)
                            targetPin.description += " " + lineData[j]
                    }
                }
            }
        }

        console.log(overlays)
        for (var i = 0; i < overlays.length; ++i) {
            overlaySelector.selectOverlay(overlays[i])
        }
    }

    function loadColorMap() {
        configFile.url = ":/qml/colormap.txt"
        configFile.load()

        if (configFile.error == true)
        {
            console.log("file error")
            return
        }

        var lines = configFile.data.split("\n")             // split it into seperate lines
        var colorMap = []

        for (var i = 0; i < lines.length; ++i)
        {
            if ((lines[i] === "") || (lines[i][0] === "#"))
                continue

            var data = lines[i].replace(/\s+/g, ' ').split(" ")
            colorMap.push(data)
        }

        return colorMap
    }

    function saveConfig(fileName) {
        var data = ""

        data += "# File generated with BB pin configurator\n"

        // exporting overlays
        for (var i = 0; i < overlaySelector.output.length; ++i)
        {
            data += "overlay " + overlaySelector.output[i] + "\n"
        }

        // exporting pins
        for (var i = 0; i < portList.length; ++i)
        {
            var port = i+8
            for (var j = 0; j < portList[i].pinList.length; ++j)
            {
                var sourcePin = portList[i].pinList[j]
                var pin = j+1

                if (!sourcePin.editable)    // this is a reserved pin
                    continue;

                var pinName = "P" + port + "_" + pin
                var command = pinName + " " + sourcePin.type
                if (sourcePin.description.length > 0)
                {
                    command += " #" + sourcePin.description
                }

                data += command + "\n"
            }
        }

        configFile.url = fileName
        configFile.data = data
        configFile.save()

        if (configFile.error)
        {
            console.log("file error")
        }
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
            anchors.topMargin: selector.width * 0.09
            width: selector.width * 0.2
            height: selector.height * 0.14
            title: qsTr("Overlays")
        }

        ConfigModeSelector {
            id: configModeSelector
            anchors.left: parent.left
            anchors.top: overlaySelector.bottom
            anchors.leftMargin: selector.width * 0.02
            anchors.topMargin: selector.width * 0.02
            width: selector.width * 0.2
            height: selector.height * 0.14
            title: qsTr("Config Mode")
            input: [qsTr("Pin function"), qsTr("GPIO direction"), qsTr("GPIO value")]
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

        Button {
            id: newButton
            anchors.left: parent.left
            anchors.bottom: loadButton.top
            anchors.leftMargin: selector.width * 0.02
            anchors.bottomMargin: selector.width * 0.02
            text: qsTr("&New")
            iconName: "document-new"

            onClicked: {
                currentFile = ""
                loadPinmux()
            }

            action: Action {
                shortcut: "Ctrl+N"
                tooltip: qsTr("Create a new config")
            }
        }

        Button {
            id: loadButton
            anchors.left: parent.left
            anchors.bottom: saveAsButton.top
            anchors.leftMargin: selector.width * 0.02
            anchors.bottomMargin: selector.width * 0.02
            text: qsTr("&Open...")
            iconName: "document-open"

            onClicked: fileOpenDialog.visible = true

            action: Action {
                shortcut: "Ctrl+O"
                tooltip: qsTr("Open a config file..")
            }
        }

        Button {
            id: saveAsButton
            anchors.left: parent.left
            anchors.bottom: saveButton.top
            anchors.leftMargin: selector.width * 0.02
            anchors.bottomMargin: selector.width * 0.02
            text: qsTr("Save &As..")
            iconName: "document-save-as"

            onClicked: fileSaveDialog.visible = true

            action: Action {
                shortcut: "Ctrl+Shift+S"
                tooltip: qsTr("Saves the config file as..")
            }
        }

        Button {
            id: saveButton
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: selector.width * 0.02
            anchors.bottomMargin: selector.width * 0.02
            text: qsTr("&Save")
            iconName: "document-save"

            onClicked: currentFile == "" ? fileSaveDialog.visible = true : saveConfig(currentFile)

            action: Action {
                shortcut: "Ctrl+S"
                tooltip: qsTr("Saves the config file")
            }
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
                loadPinmux()
                loadConfig(fileUrl)
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
                saveConfig(fileUrl)
            }
            onRejected: {
                console.log("Canceled")
            }
        }

        Item {
            property var currentColorMap: []

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

                Text {
                    id: titleText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: parent.height * 0.01
                    font.pixelSize: parent.width * 0.03
                    font.bold: true
                    text: qsTr("BeagleBone Universal IO Configurator")
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
