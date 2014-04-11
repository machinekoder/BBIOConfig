/*
  Part of QML ToolTip from bobbaluba
  https://github.com/bobbaluba/qmltooltip
 */
import QtQuick 2.0
import QtQuick.Controls 1.1

Rectangle {
    property int verticalPadding: 1
    property int horizontalPadding: 5

    width: childrenRect.width + 10
    height: childrenRect.height + 10

    id:tooltip
    visible:false
    onVisibleChanged: if(visible)fadein.start();

    NumberAnimation {
        id: fadein
        target: tooltip
        property: "opacity"
        easing.type: Easing.InOutQuad
        duration: 300
        from: 0
        to: 1
    }

    NumberAnimation {
        id: fadeout
        target: tooltip
        property: "opacity"
        easing.type: Easing.InOutQuad
        from: 1
        to: 0
        onStopped: visible = false;
    }

    function show(){
        visible = true;
        fadein.start();
    }
    function hide(){
        fadeout.start();
    }
}
