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
