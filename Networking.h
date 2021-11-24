#ifndef __Networking__
#define __Networking__

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>

class Networking : public QObject
{
    Q_OBJECT

public:
    Networking(QObject* parent = nullptr) : QObject(parent) { }
    virtual ~Networking() { }

    Q_INVOKABLE void clearAccessCache();

    static QObject* singletonProvider(QQmlEngine*, QJSEngine* ) { return new Networking; }

};

#endif
