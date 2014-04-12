TEMPLATE = app

QT += qml quick widgets
QT -= network

SOURCES += main.cpp \
    fileio.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

OTHER_FILES += \
    qml/Pin.qml \
    qml/Port.qml \
    qml/Legend.qml \
    qml/pinmux.txt \
    qml/testconfig.txt \
    qml/ToolTip.qml \
    qml/ToolTipArea.qml \
    qml/OverlaySelector.qml \
    qml/colormap.txt \
    qml/ConfigModeSelector.qml \
    qml/colormap1.txt \
    qml/colormap2.txt \
    qml/Functions.js \
    LICENSE

HEADERS += \
    fileio.h
