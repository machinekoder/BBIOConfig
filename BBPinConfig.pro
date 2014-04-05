TEMPLATE = app

QT += qml quick widgets

SOURCES += main.cpp \
    fileio.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

OTHER_FILES += \
    qml/Pin.qml \
    qml/MenuEntry.qml \
    qml/Port.qml \
    qml/Legend.qml \
    qml/pinmux.txt \
    qml/testconfig.txt

HEADERS += \
    fileio.h
