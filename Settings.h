#ifndef __Settings__
#define __Settings__

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT

public:
    Settings(QObject* parent = nullptr);
    virtual ~Settings() { }

    Q_INVOKABLE QVariant value(const QString& key, const QVariant& defaultValue = QVariant());
    Q_INVOKABLE void setValue(const QString& key, const QVariant& value);

    static QObject* singletonProvider(QQmlEngine*, QJSEngine* ) { return new Settings; }

protected:
    QSettings* m_Settings;

};

#endif
