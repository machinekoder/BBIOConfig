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
    property var input: ["test", "test2", "test3"]
    property var output: []
    property string hoveredItem: ""

    id: main
    width: 300
    height: 200

    ListModel {
        id: listModel

    }

    ListView {
        id: listView
        anchors.fill: parent
        model: listModel
        delegate:
            CheckBox {
                text: name
                checked: itemChecked
                onClicked: selectionChanged(index, checked)
                onHoveredChanged: hovered ? main.hoveredItem = text : main.hoveredItem = ""
            }
    }

    onInputChanged: {
        listModel.clear()
        output = []
        for (var i = 0; i < input.length; ++i)
        {
            listModel.append({"name": input[i], "index": i, "itemChecked": false})
        }
    }

    function selectionChanged(id, value) {
        var output = main.output
        if (value === true)
        {
            output.push(input[id])
        }
        else
        {
            var foundIndex = output.indexOf(input[id])
            if (foundIndex > -1)
            {
                output.splice(foundIndex, 1)
            }
        }

        main.output = output
    }

    function clearSelection() {
        for (var i = 0; i < input.length; ++i) {
            listModel.get(i).itemChecked = false
        }
        main.output = []
    }

    function selectOverlay(name) {
        var index = input.indexOf(name)

        if (index == -1) {
            console.log("unknown overlay")
            return
        }

        listModel.get(index).itemChecked = true
        selectionChanged(index, true)
    }
}
