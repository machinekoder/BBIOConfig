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
function loadPinmux()
{
    var functions = []
    var capes = []

    configFile.url = ":/bbioconfig/qml/pinmux.txt"
    configFile.load()

    if (configFile.error == true)
    {
        console.log("file error")
        return
    }

    // first set all pins to reserved
    for (var j = 0; j < portList.length; ++j)
    {
        for (var i = 0; i < portList[j].pinList.length; ++i)
        {
            var pin = portList[j].pinList[i]
            pin.functions = ["reserved"]
            pin.info = ["reserved"]
            pin.type = "reserved"
            pin.description = ""
            pin.overlay = ""
            pin.gpioDirection = "unmodified"
            pin.gpioValue = "unmodified"
            pin.kernelPinNumber = 0
            pin.pruPinNumber = 0
        }
    }

    var lines = configFile.data.split("\n")             // split it into seperate lines
    for (var i = 0; i < lines.length; ++i)
    {
        var line = lines[i]
        if ((line.length === 0) || (line[0] === "#"))   // skip empty and comment lines
            continue;

        var lineData = line.split("=")                  // split the line into a left and right side
        lineData[1] = lineData[1].replace("\"","")      // remove quote marks from the right side
        lineData[1] = lineData[1].replace("\"","")
        var functionsData = lineData[1].split(" ")
        var pinmuxData = lineData[0].split("_")         // split the left side into port, pin and type

        var port = parseInt(pinmuxData[0].substr(1),10) // Port, P<n>
        var pin = parseInt(pinmuxData[1],10)            // Pin <n>
        var type = pinmuxData[2]                        // Type: PINMUX, INFO, CAPE

        for (var j = 0; j < functionsData.length; ++j)  // convert the right side into a list of strings
        {
            var func = functionsData[j]

            switch(type) {
            case "PINMUX":
                if ((functions.indexOf(func) == -1) && (func !== ""))          // this has no use yet
                {
                    functions.push(func)
                }
                break;
            case "CAPE":
                if ((capes.indexOf(func) == -1) && (func !== ""))          // this has no use yet
                {
                    capes.push(func)
                }
                break;
            default:
            }
        }

        if ((port === 8) || (port === 9))               // BB has only P8 and P9
        {
            if (pin <= portList[port-8].pinList.length) // BB has 46 pins per port
            {
                var targetPin = portList[port-8].pinList[pin-1]
                switch(type) {
                case "PINMUX":
                    targetPin.functions = functionsData
                    targetPin.type = functionsData[0]
                    break;
                case "PIN":
                    targetPin.defaultFunction = functionsData[0]
                    break;
                case "INFO":
                    targetPin.info = functionsData
                    break;
                case "CAPE":
                    targetPin.overlay = functionsData[0]
                    break;
                case "PRU":
                    targetPin.pruPinNumber = parseInt(functionsData[0])
                    break;
                case "GPIO":
                    targetPin.kernelPinNumber = parseInt(functionsData[0])
                    break;
                default:
                }

            }
        }
    }
    //console.log(functions)
    overlaySelector.input = capes

    //now everthing should be loaded -> reset modified
    modified = false
}

function loadColorMap(fileName) {
    configFile.url = fileName
    configFile.load()

    if (configFile.error == true)
    {
        console.log("file error")
        return
    }

    var lines = configFile.data.split("\n")             // split it into seperate lines
    var colorMap = []

    for (var i = 0; i < lines.length; ++i)
    {
        if ((lines[i] === "") || (lines[i][0] === "#"))
            continue

        var data = lines[i].replace(/\s+/g, ' ').split(" ")
        colorMap.push(data)
    }

    return colorMap
}

function loadConfig(fileName)
{
    configFile.url = fileName
    configFile.load()

    if (configFile.error == true)
    {
        console.log("file error")
        return false
    }

    var lines = configFile.data.split("\n");

    if (lines.length === 0)
        return true

    var overlays = []
    overlaySelector.clearSelection()    // clear selected overlays
    documentTitle = ""

    for (var i = 0; i < lines.length; ++i)
    {
        var line = lines[i]
        var titleText = "# title: "

        if (line.indexOf(titleText)  === 0)             // get the document title
            documentTitle = line.substring(titleText.length)

        if ((line.length === 0) || (line[0] === "#"))   // skip empty and comment lines
            continue;

        var lineDataRaw = line.split(" ")
        var lineData = []
        for (var j = 0; j < lineDataRaw.length; ++j)
        {
            var lineDataRawLine = lineDataRaw[j]
            if (lineDataRawLine.length > 0)
            {
                lineData.push(lineDataRawLine.replace("#",""))
            }
        }

        if (lineData.length === 0)
            continue

        var overlayCheckText = lineData[0].toLowerCase()
        switch (overlayCheckText) {
        case "overlay":
        case "ov":
        case "cape":
            overlays.push(lineData[1])
            continue;
        default:
        }

        var pinmuxData = lineData[0].split("_")

        if (pinmuxData[0][0].toString().toUpperCase() === "P") // remove the leading P
        {
            pinmuxData[0] = pinmuxData[0].substr(1)
        }

        var port = parseInt(pinmuxData[0],10)
        var pin = parseInt(pinmuxData[1],10)

        if ((port === 8) || (port === 9))
        {
            if (pin <= portList[port-8].pinList.length)
            {
                var targetPin = portList[port-8].pinList[pin-1]

                //right hand value
                switch (lineData[1].toLowerCase()) {
                case "in":
                case "input":
                    targetPin.type = "gpio"
                    targetPin.gpioDirection = "in"
                    break;
                case "out":
                case "output":
                    targetPin.type = "gpio"
                    targetPin.gpioDirection = "out"
                    break;
                case "hi":
                case "high":
                case "1":
                    targetPin.type = "gpio"
                    targetPin.gpioDirection = "out"
                    targetPin.gpioValue = "high"
                    break;
                case "lo":
                case "low":
                case "0":
                    targetPin.type = "gpio"
                    targetPin.gpioDirection = "out"
                    targetPin.gpioValue = "low"
                    break;
                case "in+":
                case "input+":
                    targetPin.type = "gpio_pu"
                    targetPin.gpioDirection = "in"
                    break;
                case "in-":
                case "input-":
                    targetPin.type = "gpio_pd"
                    targetPin.gpioDirection = "in"
                    break
                case "out+":
                case "output+":
                    targetPin.type = "gpio_pu"
                    targetPin.gpioDirection = "out"
                    break;
                case "out-":
                case "output-":
                    targetPin.type = "gpio_pd"
                    targetPin.gpioDirection = "out"
                    break;
                case "hi+":
                case "high+":
                case "1+":
                    targetPin.type = "gpio_pu"
                    targetPin.gpioDirection = "out"
                    targetPin.gpioValue = "high"
                    break;
                case "hi-":
                case "high-":
                case "1-":
                    targetPin.type = "gpio_pd"
                    targetPin.gpioDirection = "out"
                    targetPin.gpioValue = "high"
                    break;
                case "lo+":
                case "low+":
                case "0+":
                    targetPin.type = "gpio_pu"
                    targetPin.gpioDirection = "out"
                    targetPin.gpioValue = "low"
                    break;
                case "lo-":
                case "low-":
                case "0-":
                    targetPin.type = "gpio_pd"
                    targetPin.gpioDirection = "out"
                    targetPin.gpioValue = "low"
                    break;
                default:
                    targetPin.type = lineData[1]
                }

                if (lineData.length > 2)
                {
                    targetPin.description = lineData[2]
                    for (var j = 3; j < lineData.length; ++j)
                        targetPin.description += " " + lineData[j]
                }
            }
        }
    }

    //console.log(overlays)
    for (var i = 0; i < overlays.length; ++i) {
        overlaySelector.selectOverlay(overlays[i])
    }

    modified = false

    return true
}

function saveConfig(fileName) {
    var data = ""

    data += "# File generated with BB pin configurator\n"
    data += "# title: " + documentTitle + "\n"

    // exporting overlays
    for (var i = 0; i < overlaySelector.output.length; ++i)
    {
        data += "overlay " + overlaySelector.output[i] + "\n"
    }

    // exporting pins
    for (var i = 0; i < portList.length; ++i)
    {
        var port = i+8
        for (var j = 0; j < portList[i].pinList.length; ++j)
        {
            var sourcePin = portList[i].pinList[j]
            var pin = j+1

            if (sourcePin.overlay === "")    // this is a reserved pin
                continue
            if (sourcePin.loadedOverlays.indexOf(sourcePin.overlay) === -1) // overlay not loaded
                continue

            var pinName = "P" + port + "_" + pin
            var command = pinName + " "

            if (sourcePin.type === "gpio")
            {
                if ((sourcePin.gpioValue !== "unmodified") && (sourcePin.gpioDirection === "out"))
                {
                    command += sourcePin.gpioValue
                }
                else if (sourcePin.gpioDirection !== "unmodified")
                {
                    command += sourcePin.gpioDirection
                }
                else
                {
                    command += "gpio"
                }
            }
            else if (sourcePin.type === "gpio_pu")
            {
                if ((sourcePin.gpioValue !== "unmodified") && (sourcePin.gpioDirection === "out"))
                {
                    command += sourcePin.gpioValue + "+"
                }
                else if (sourcePin.gpioDirection !== "unmodified")
                {
                    command += sourcePin.gpioDirection + "+"
                }
                else
                {
                    command += "gpio_pu"
                }
            }
            else if (sourcePin.type === "gpio_pd")
            {
                if ((sourcePin.gpioValue !== "unmodified") && (sourcePin.gpioDirection === "out"))
                {
                    command += sourcePin.gpioValue + "-"
                }
                else if (sourcePin.gpioDirection !== "unmodified")
                {
                    command += sourcePin.gpioDirection + "-"
                }
                else
                {
                    command += "gpio_pd"
                }
            }
            else
            {
                command += sourcePin.type
            }

            if (sourcePin.description.length > 0)
            {
                command += " #" + sourcePin.description
            }

            data += command + "\n"
        }
    }

    configFile.url = fileName
    configFile.data = data
    configFile.save()

    if (configFile.error)
    {
        console.log("file error")
        return false
    }

    modified = false

    return true
}

function rgb2hsv (color) {
 var computedH = 0;
 var computedS = 0;
 var computedV = 0;
 var r = color.r;
 var g = color.g;
 var b = color.b;

 var minRGB = Math.min(r,Math.min(g,b));
 var maxRGB = Math.max(r,Math.max(g,b));

 // Black-gray-white
 if (minRGB === maxRGB) {
  computedV = minRGB;
  return {h: 0, s: 0, v: computedV};
 }

 // Colors other than black-gray-white:
 var d = (r === minRGB) ? g-b : ((b === minRGB) ? r-g : b-r);
 var h = (r === minRGB) ? 3 : ((b === minRGB) ? 1 : 5);
 computedH = 60*(h - d/(maxRGB - minRGB));
 computedS = (maxRGB - minRGB)/maxRGB;
 computedV = maxRGB;
 return {h: computedH, s: computedS, v: computedV};
}
