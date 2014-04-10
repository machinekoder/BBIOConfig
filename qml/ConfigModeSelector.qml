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
import QtQuick.Layouts 1.0

GroupBox {
    property var input: ["test", "test2", "test3"]
    property int currentIndex: 0

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
            RadioButton {
                text: name
                exclusiveGroup: group
                checked: radioChecked
                onClicked: selectionChanged(index, checked)
            }
    }

    ExclusiveGroup { id: group }

    onInputChanged: {
        currentIndex = 0
        listModel.clear()
        for (var i = 0; i < input.length; ++i)
        {
            listModel.append({"name": input[i], "index": i, "radioChecked": (i == 0)})
        }
    }

    function selectionChanged(index, checked) {
        if (checked) {
            currentIndex = index
        }
    }
}
