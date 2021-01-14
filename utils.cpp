#include "utils.h"
#include <QSqlField>

QSqlField field(const QString &key, QVariant::Type type, QVariant value)
{
    QSqlField f(key, type);
    f.setValue(value);
    return f;
}
