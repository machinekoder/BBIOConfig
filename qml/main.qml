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
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1

ApplicationWindow {
    property string name: qsTr("BB Universal IO Configurator (BBIOConfig)")

    id: applicationWindow

    title: (bbioConfig.currentFileName + (bbioConfig.modified? qsTr(" [modified] ") : "") + " - ") + applicationWindow.name
    visible: true
    width: 1000
    height: 800

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&New")
                iconName: "document-new"

                onTriggered: aboutToCreateNewDocument()

                action: Action {
                    shortcut: "Ctrl+N"
                    tooltip: qsTr("Create a new config")
                }
            }

            MenuItem {
                text: qsTr("&Open...")
                iconName: "document-open"

                onTriggered: fileOpenDialog.visible = true

                action: Action {
                    shortcut: "Ctrl+O"
                    tooltip: qsTr("Open a config file..")
                }
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("&Save")
                iconName: "document-save"

                onTriggered: bbioConfig.currentFile == "" ? fileSaveDialog.visible = true : bbioConfig.saveDocument("")

                action: Action {
                    shortcut: "Ctrl+S"
                    tooltip: qsTr("Saves the config file")
                }
            }

            MenuItem {
                text: qsTr("Save &As..")
                iconName: "document-save-as"

                onTriggered: fileSaveDialog.visible = true

                action: Action {
                    shortcut: "Ctrl+Shift+S"
                    tooltip: qsTr("Saves the config file as..")
                }
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("E&xit")
                iconName: "application-exit"

                onTriggered: aboutToClose()

                action: Action {
                    shortcut: "Ctrl+Q"
                    tooltip: qsTr("Exit")
                }
            }
        }
        Menu {
            title: qsTr("&Help")
            MenuItem {
                text: qsTr("&Online Documentation")
                iconName: "help-contents"

                onTriggered: Qt.openUrlExternally("https://github.com/strahlex/BBIOConfig/wiki/User-Manual")
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("&About")
                iconName: "help-about"

                onTriggered: aboutDialog.visible = true
            }
        }
    }

    function aboutToClose() {
        if (bbioConfig.modified)
        {
            quitSaveDialog.quit = true
            quitSaveDialog.visible = true
        }
        else {
            Qt.quit()
        }
    }

    function aboutToCreateNewDocument() {
        if (bbioConfig.modified)
        {
            quitSaveDialog.quit = false
            quitSaveDialog.visible = true
        }
        else {
            bbioConfig.newDocument()
        }
    }

    onClosing: {
        close.accepted = false
        aboutToClose() === false
    }

    MessageDialog {
        id: aboutDialog
        title: qsTr("About BBIOConfig")
        text: qsTr("<h2>BeagleBone Universal IO Configurator<br>" +
                   "BBIOConfig</h2> <br>" +
                   "Copyright (C) 2014 by Alexander Rössler (<a href='mailto:mail.aroessler@gmail.com'>mail.aroessler@gmail.com</a>)<br><br>" +
                   "BBIOConfig is free software: you can redistribute it and/or modify<br>" +
                   "it under the terms of the GNU General Public License as published by<br>" +
                   "the Free Software Foundation, either version 3 of the License, or<br>" +
                   "(at your option) any later version.<br><br>" +

                   "BBIOConfig is distributed in the hope that it will be useful,<br>" +
                   "but WITHOUT ANY WARRANTY; without even the implied warranty of<br>" +
                   "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the<br>" +
                   "GNU General Public License for more details.<br><br>" +

                   "You should have received a copy of the GNU General Public License<br>" +
                   "along with BBIOConfig.  If not, see <http://www.gnu.org/licenses/>.<br>")
    }

    FileDialog {
        id: fileOpenDialog
        title: qsTr("Please choose a io file")
        selectExisting: true
        nameFilters: [ "BB Universion IO file (*.bbio)", "All files (*)" ]
        onAccepted: {
            bbioConfig.openDocument(fileUrl)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    FileDialog {
        id: fileSaveDialog
        title: qsTr("Please choose a io file")
        selectExisting: false
        nameFilters: [  qsTr("BB Universion IO file (*.bbio)"), qsTr("All files (*)") ]
        onAccepted: {
            bbioConfig.saveDocument(fileUrl)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    MessageDialog {
        property bool quit: false

        id: quitSaveDialog
        title: qsTr("Save Documents") + " - " + applicationWindow.name
        text: qsTr("The document has been modified. Do you want to save them before closing?")
        standardButtons: StandardButton.Discard | StandardButton.Save | StandardButton.Cancel
        onAccepted: {
            if (bbioConfig.currentFile == "")
            {
                fileSaveDialog.visible = true
            }
            if (bbioConfig.currentFile != "")
            {
                bbioConfig.saveDocument("")
                if (quit)
                    Qt.quit()
                else
                    bbioConfig.newDocument()
            }
        }
        onRejected: {
            // Don't close
        }
        onDiscard: {
            if (quit)
                Qt.quit()
            else
                bbioConfig.newDocument()
        }
    }

    BBIOConfig {
        id: bbioConfig
        anchors.fill: parent
    }
}
