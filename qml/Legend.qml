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
import QtQuick.Controls 1.0

GroupBox {
    property var colorMap: [["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]
    property var pinList: []
    property string previewType: ""
    property bool previewEnabled: false
    property int pinSize: main.width*0.125
    property int pinSpacing: 2

    id: main
    width: 100
    title: qsTr("Legend")

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
        columns: 1
        rows: colorMap.length
        spacing: main.pinSpacing
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

        //main.height = colorMap.length * (main.pinSize + main.pinSpacing) + 30
    }

    function createPin(number) {
        var component;
        var sprite;
        var numberVisible;

        numberVisible =  false

         component = Qt.createComponent("Pin.qml");
         sprite = component.createObject(grid, {"width": Qt.binding(function(){return main.pinSize}),
                                             "height": Qt.binding(function(){return main.pinSize}),
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

    function previewEntered(type) {
        main.previewType = type
        main.previewEnabled = true
    }

    function previewExited() {
        main.previewEnabled = false
    }
}
