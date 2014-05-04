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
#include <QApplication>
#include <QQmlApplicationEngine>
#include "fileio.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<FileIO>("FileIO", 1, 0, "File");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///bbioconfig/qml/main.qml")));

    return app.exec();
}
