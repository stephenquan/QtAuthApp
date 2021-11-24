#include "NetworkRequest.h"
#include <QUrlQuery>
#include <QNetworkReply>
#include <QQmlEngine>
#include <QDebug>

NetworkRequest::NetworkRequest(QObject* parent) :
    QObject(parent),
    m_ReadyState(ReadyState::ReadyStateUninitialized),
    m_Status(0)
{
}

void NetworkRequest::send(const QVariant& body)
{
    if (m_Url.isEmpty())
    {
        qDebug() << Q_FUNC_INFO << "url empty";
        return;
    }

    if (!m_Url.isValid())
    {
        qDebug() << Q_FUNC_INFO << "url !valid";
        return;
    }

    if (!body.isValid() || body.isNull())
    {
        send(m_Url, m_Method, QByteArray());
        return;
    }

    if (body.canConvert(QVariant::Map))
    {
        send(body.toMap());
        return;
    }
}

void NetworkRequest::send(const QVariantMap& body)
{
    qDebug() << Q_FUNC_INFO << body;

    QUrl updatedUrl = m_Url;
    QUrlQuery urlQuery(m_Url.query());
    for (QVariantMap::const_iterator iter = body.begin(); iter != body.end(); ++iter)
    {
        QString key = iter.key();
        QString value = iter.value().toString();
        if (urlQuery.hasQueryItem(key))
        {
            urlQuery.removeQueryItem(key);
        }
        urlQuery.addQueryItem(key, value);
    }
    QByteArray postData = urlQuery.toString(QUrl::FullyEncoded).toUtf8();
    updatedUrl.setQuery(postData);
    qDebug() << "updatedUrl: " << updatedUrl;

    QUrl baseUrl = m_Url;
    baseUrl.setQuery(QString());

    if (m_Method.compare("POST", Qt::CaseInsensitive) == 0)
    {
        send(baseUrl, "POST", postData);
    }
    else if (m_Method.compare("PUT", Qt::CaseInsensitive) == 0)
    {
        send(baseUrl, "PUT", postData);
    }
    else if (m_Method.compare("DELETE", Qt::CaseInsensitive) == 0)
    {
        send(baseUrl, "DELETE", postData);
    }
    else if (m_Method.compare("HEAD", Qt::CaseInsensitive) == 0)
    {
        send(updatedUrl, "HEAD", QByteArray());
    }
    else
    {
        send(updatedUrl, "GET", QByteArray());
    }
}

void NetworkRequest::send(const QUrl& url, const QString& method, const QByteArray& body)
{
    QQmlEngine* engine = qmlEngine(this);
    if (!engine)
    {
        qDebug() << Q_FUNC_INFO << "!engine";
        return;
    }

    QNetworkAccessManager* manager = engine->networkAccessManager();
    if (!manager)
    {
        qDebug() << Q_FUNC_INFO << "!manager";
        return;
    }

    setReadyState(ReadyState::ReadyStateSending);
    setStatus(0);
    setResponse(QByteArray());
    m_ResponseHeaders.clear();
    emit responseHeadersChanged();

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::KnownHeaders::ContentTypeHeader,  "application/x-www-form-urlencoded");

    QNetworkReply * reply = nullptr;
    if (method.compare("POST", Qt::CaseInsensitive) == 0)
    {
        qDebug() << "post: url: " << url << "body: " << body;
        reply = manager->post(request, body);
    }
    else if (method.compare("PUT", Qt::CaseInsensitive) == 0)
    {
        reply = manager->put(request, body);
    }
    else if (method.compare("DELETE", Qt::CaseInsensitive) == 0)
    {
        if (body.isNull())
        {
            reply = manager->deleteResource(request);
        }
        else
        {
            static QByteArray kDELETE = QString("DELETE").toUtf8();
            reply = manager->sendCustomRequest(request, kDELETE, body);
        }
    }
    else if (method.compare("HEAD", Qt::CaseInsensitive) == 0)
    {
        reply = manager->head(request);
    }
    else
    {
        reply = manager->get(request);
    }

    connect(reply, &QNetworkReply::finished, this, &NetworkRequest::onFinished);
}

void NetworkRequest::setReadyState(ReadyState readyState)
{
    if (m_ReadyState == readyState)
    {
        return;
    }

    m_ReadyState = readyState;

    emit readyStateChanged();
}

void NetworkRequest::setResponse(const QByteArray& response)
{
    if (m_Response == response)
    {
        return;
    }

    m_Response = response;

    emit responseChanged();
}

void NetworkRequest::onFinished()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply)
    {
        return;
    }

    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    setStatus(status);

    m_ResponseHeaders.clear();
    foreach (const auto& rawHeaderPair, reply->rawHeaderPairs())
    {
        QString key = QString::fromUtf8(rawHeaderPair.first);
        QString value = QString::fromUtf8(rawHeaderPair.second);
        m_ResponseHeaders[key] = value;
    }
    emit responseHeadersChanged();

    QByteArray response = reply->readAll();

    setResponse(response);

    qDebug() << Q_FUNC_INFO << "status: " << status << "response: " << response;

    setReadyState(ReadyState::ReadyStateComplete);
}

void NetworkRequest::setStatus(int statusCode)
{
    if (m_Status == statusCode)
    {
        return;
    }

    m_Status = statusCode;

    emit statusChanged();
}
