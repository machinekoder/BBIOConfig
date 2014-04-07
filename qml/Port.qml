import QtQuick 2.0

Rectangle {
    property var pinList: []
    property var currentColorMap: [[["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]]

    id: main

    width: 50
    height: 500
    color: "white"
    border.color: "black"
    border.width: 2

    Grid {
        id: grid
        spacing: 2
        columns: 2
        anchors.centerIn: parent

        Component.onCompleted: {
            var numPins = 46
            for (var i = 1; i < (numPins+1); ++i)
            {
                createPin(i)
            }
        }
    }

    function createPin(number) {
        var component;
        var sprite;
        var numberVisible;

        numberVisible =  ((number % 10 == 0) || (number % 10 == 9) || (number == 1) || (number == 2))

         component = Qt.createComponent("Pin.qml");
         sprite = component.createObject(grid, {"width": main.width*0.38,
                                             "height": main.width*0.38,
                                             "number": number,
                                             "numberVisible": numberVisible,
                                             "colorMap": main.currentColorMap,
                                             "functions": []});

         if (sprite === null) {
             // Error Handling
             console.log("Error creating object");
         }

         main.pinList.push(sprite)
     }

    function createTabOrder() {
        var numPins = 46
        // set tab order
        for (var i = 0; i < (numPins-1); ++i)
        {
            // skip reserved pins
            if (!pinList[i].editable)
                continue;

            // search tab
            for (var j = i+1; j < numPins; ++j)
            {
                if (pinList[j].editable) {
                    pinList[i].textInput.KeyNavigation.tab = pinList[j].textInput
                    break;
                }
            }

            // search up and down
            for (var j = i+2; j < numPins; j += 2)
            {
                if (pinList[j].editable) {
                    pinList[i].textInput.KeyNavigation.down = pinList[j].textInput
                    break;
                }
            }
        }
    }

}

