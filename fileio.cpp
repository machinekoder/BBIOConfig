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
#include "fileio.h"

FileIO::FileIO(QQuickItem *parent) :
    QQuickItem(parent)
{
    m_url = QStringLiteral("");
    m_data = QStringLiteral("");
    m_error = false;
}

void FileIO::save()
{
    QUrl  url(m_url);
    QString fileName = m_url;

    if (url.isLocalFile())
    {
        fileName = url.toLocalFile();
    }

    QFile file(fileName);

    if (file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        file.write(m_data.toLocal8Bit());
        file.close();
        m_error = false;
        emit saved();
        emit errorChanged(m_error);
    }
    else
    {
        m_error = true;
        //emit error("Cannot open file to write");
        emit errorChanged(m_error);
    }
}

void FileIO::load()
{
    QUrl  url(m_url);
    QString fileName = m_url;

    if (url.isLocalFile())
    {
        fileName = url.toLocalFile();
    }

    QFile file(fileName);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        m_data = QString::fromLocal8Bit(file.readAll());
        emit dataChanged(m_data);
        file.close();
        m_error = false;
        emit loaded();
        emit errorChanged(m_error);
    }
    else
    {
        m_error = true;
        //emit error("Cannot open file to read");
        emit errorChanged(m_error);
    }
}
