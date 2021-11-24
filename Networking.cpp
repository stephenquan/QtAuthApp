#include "Networking.h"
#include <QQmlEngine>
#include <QNetworkAccessManager>

void Networking::clearAccessCache()
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

    manager->clearAccessCache();
}
