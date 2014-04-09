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
