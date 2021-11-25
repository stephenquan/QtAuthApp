#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QNetworkProxy>
#include "NetworkRequest.h"
#include "Networking.h"
#include "Settings.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("stephenquan");
    QCoreApplication::setOrganizationDomain("github.com");
    QCoreApplication::setApplicationName("QtAuthApp");

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // QNetworkProxy::setApplicationProxy(QNetworkProxy(QNetworkProxy::HttpProxy, "localhost", 8081));

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<NetworkRequest>("QtAuthApp", 1, 0, "NetworkRequest");
    qmlRegisterSingletonType<Networking>("QtAuthApp", 1, 0, "Networking", Networking::singletonProvider);
    qmlRegisterSingletonType<Settings>("QtAuthApp", 1, 0, "Settings", Settings::singletonProvider);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
