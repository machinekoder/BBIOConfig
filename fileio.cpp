#include "fileio.h"

FileIO::FileIO(QQuickItem *parent) :
    QQuickItem(parent)
{
    m_url = "";
    m_data = "";
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
        m_data = QString(file.readAll());
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
