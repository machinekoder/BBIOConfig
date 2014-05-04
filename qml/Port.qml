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

Rectangle {
    property int pinCount: 46
    property int pinRows: 2
    property int pinNumberingInterval: 5
    property var pinList: []
    property var currentColorMap: [[["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]]
    property var loadedOverlays: []
    property string previewType: ""
    property bool previewEnabled: false
    property int configMode: 0
    property int portNumber: 0
    property bool displayUneditablePins: true
    property bool ready: false

    signal dataChanged()

    function createPin(number, numPins) {
        var component;
        var sprite;
        var numberVisible;

        numberVisible =  ((number % (main.pinNumberingInterval*main.pinRows) == 0)
                          || (number % (main.pinNumberingInterval*main.pinRows) == ((main.pinNumberingInterval-1)*main.pinRows+1))
                          || (number === 1)
                          || (number === main.pinRows))

         component = Qt.createComponent("Pin.qml");
         sprite = component.createObject(grid, {"width": Qt.binding(function(){return main.width*0.38}),
                                             "height": Qt.binding(function(){return main.width*0.38}),
                                             "pinNumber": number,
                                             "portNumber": Qt.binding(function(){return main.portNumber}),
                                             "numberVisible": numberVisible,
                                             "colorMap": Qt.binding(function(){return main.currentColorMap}),
                                             "functions": [],
                                             "loadedOverlays": Qt.binding(function(){return main.loadedOverlays}),
                                             "previewType": Qt.binding(function(){return main.previewType}),
                                             "previewEnabled": Qt.binding(function(){return main.previewEnabled}),
                                             "configMode": Qt.binding(function(){return main.configMode}),
                                             "displayUneditablePins": Qt.binding(function(){return main.displayUneditablePins}),
                                             "z": numPins-number});

         if (sprite === null) {
             // Error Handling
             console.log("Error creating object");
         }

         sprite.onDataChanged.connect(main.dataChanged)

         main.pinList.push(sprite)
     }

    function createTabOrder() {
        var numPins = main.pinCount
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

    id: main

    width: 50
    height: 500
    color: "white"
    border.color: "black"
    border.width: 2

    Component.onCompleted: {
        var numPins = main.pinCount
        for (var i = 1; i < (numPins+1); ++i)
        {
            createPin(i, numPins)
        }

        main.ready = true
    }

    Grid {
        id: grid
        spacing: 2
        columns: main.pinRows
        anchors.centerIn: parent
    }
}

