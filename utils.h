#ifndef UTILS_H
#define UTILS_H

#include <QSqlField>

QSqlField field(const QString &key, QVariant::Type type, QVariant value);

#endif // UTILS_H
