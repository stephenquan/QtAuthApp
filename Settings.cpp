#include "Settings.h"
#include <QDebug>

Settings::Settings(QObject* parent) :
    QObject(parent),
    m_Settings(new QSettings(this))
{
}

QVariant Settings::value(const QString& key, const QVariant& defaultValue)
{
    if (!m_Settings)
    {
        qDebug() << Q_FUNC_INFO << "settings invalid";
        return defaultValue;
    }

    QVariant value = m_Settings->value(key, defaultValue);

    qDebug() << Q_FUNC_INFO << key << value;

    return value;
}

void Settings::setValue(const QString& key, const QVariant& value)
{
    qDebug() << Q_FUNC_INFO << key << value;

    if (!m_Settings)
    {
        qDebug() << Q_FUNC_INFO << "settings invalid";
        return;
    }

    return m_Settings->setValue(key, value);
}
