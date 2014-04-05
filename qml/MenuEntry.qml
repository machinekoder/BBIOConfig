import QtQuick 2.0
import QtQuick.Controls 1.1

MenuItem {
    signal clicked(string name)

    id: menuItem
    onTriggered: clicked(text)
}
