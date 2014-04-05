import QtQuick 2.0

Item {
    property var colorMap: [["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]
    property var pinList: []

    signal previewEntered(string type)
    signal previewExited()

    id: main
    width: 100
    height: 62

    Component.onCompleted: {
        refreshPins()
    }

    onColorMapChanged: {
        if (pinList == undefined)
        {
            return
        }

        refreshPins()
    }

    Grid {
        id: grid
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width *0.2
        columns: 1
        rows: colorMap.length
        spacing: 2
    }

    function refreshPins() {
        for (var i = 0; i < pinList.length; ++i)
        {
            pinList[i].destroy()
        }
        pinList = []

        for (var i = 0; i < colorMap.length; ++i)
        {
            createPin(i)
        }
    }

    function createPin(number) {
        var component;
        var sprite;
        var numberVisible;

        numberVisible =  false

         component = Qt.createComponent("Pin.qml");
         sprite = component.createObject(grid, {"width": main.width*0.15,
                                             "height": main.width*0.15,
                                             "number": number*2,
                                             "numberVisible": numberVisible,
                                             "description": main.colorMap[number][0],
                                             "colorMap": main.colorMap,
                                             "type": main.colorMap[number][0],
                                             "editable": false,
                                             "previewEnabled": true,
                                             "previewType": ""});
        sprite.type = main.colorMap[number][0]
        sprite.previewEntered.connect(main.previewEntered)
        sprite.previewExited.connect(main.previewExited)

         if (sprite === null) {
             // Error Handling
             console.log("Error creating object");
         }

         main.pinList.push(sprite)
     }
}
