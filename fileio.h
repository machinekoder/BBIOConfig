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
#ifndef FILEIO_H
#define FILEIO_H

#include <QQuickItem>
#include <QFile>

class FileIO : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QString data READ data WRITE setData NOTIFY dataChanged)
    Q_PROPERTY(bool error READ error NOTIFY errorChanged)

public:
    explicit FileIO(QQuickItem *parent = 0);

QString url() const
{
    return m_url;
}

QString data() const
{
    return m_data;
}

bool error() const
{
    return m_error;
}

signals:
    void loaded();
    void saved();

    void urlChanged(QString arg);
    void dataChanged(QString arg);

    void errorChanged(bool arg);

public slots:
    void save();
    void load();

    void setUrl(QString arg)
    {
        if (m_url != arg) {
            m_url = arg;
            emit urlChanged(arg);
        }
    }
    void setData(QString arg)
    {
        if (m_data != arg) {
            m_data = arg;
            emit dataChanged(arg);
        }
    }

private:
    QString m_url;
    QString m_data;
    bool m_error;
};

#endif // FILEIO_H
