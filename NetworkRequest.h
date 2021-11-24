#ifndef __NetworkRequest__
#define __NetworkRequest__

#include <QObject>
#include <QUrl>
#include <QVariant>
#include <QByteArray>
#include <QNetworkAccessManager>

class NetworkRequest : public QObject
{
    Q_OBJECT

    Q_PROPERTY (QString method MEMBER m_Method NOTIFY methodChanged)
    Q_PROPERTY (QUrl url MEMBER m_Url NOTIFY urlChanged)
    Q_PROPERTY (ReadyState readyState READ readyState NOTIFY readyStateChanged)
    Q_PROPERTY (QByteArray response READ response NOTIFY responseChanged)
    Q_PROPERTY (QString responseText READ responseText NOTIFY responseChanged)
    Q_PROPERTY (QVariantMap responseHeaders READ responseHeaders NOTIFY responseHeadersChanged)
    Q_PROPERTY (int status READ status NOTIFY statusChanged)

public:
    enum class ReadyState
    {
        ReadyStateUninitialized     = 0,
        ReadyStateInitialized       = 1,
        ReadyStateSending           = 2,
        ReadyStateProcessing        = 3,
        ReadyStateComplete          = 4,

        UNSENT                      = ReadyState::ReadyStateUninitialized,
        OPENED                      = ReadyState::ReadyStateInitialized,
        HEADERS_RECEIVED            = ReadyState::ReadyStateSending,
        LOADING                     = ReadyState::ReadyStateProcessing,
        DONE                        = ReadyState::ReadyStateComplete
    };
    Q_ENUMS(ReadyState)

public:
    NetworkRequest(QObject* parent = nullptr);
    virtual ~NetworkRequest() { }

    Q_INVOKABLE void send(const QVariant& body = QVariant());

signals:
    void methodChanged();
    void urlChanged();
    void readyStateChanged();
    void responseChanged();
    void responseHeadersChanged();
    void statusChanged();

protected:
    QString m_Method;
    QUrl m_Url;
    ReadyState m_ReadyState;
    QByteArray m_Response;
    QVariantMap m_ResponseHeaders;
    int m_Status;

    void send(const QVariantMap& body);
    void send(const QUrl& url, const QString& method, const QByteArray& body);
    ReadyState readyState() const { return m_ReadyState; }
    void setReadyState(ReadyState readyState);
    QByteArray response() const { return m_Response; }
    QString responseText() const { return QString::fromUtf8(response()); }
    void setResponse(const QByteArray& response);
    QVariantMap responseHeaders() const { return m_ResponseHeaders; }
    int status() const { return m_Status; }
    void setStatus(int status);

protected slots:
    void onFinished();

};

#endif
