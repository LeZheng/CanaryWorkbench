#ifndef WORKSPACE_H
#define WORKSPACE_H

#include <QObject>
#include <QJsonArray>
#include <QSettings>

class Workspace:public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
public:
    Workspace(QObject *parent = nullptr);

    static Workspace* fromJson(const QString &jsonStr);

    QString name()
    {
        return mName;
    }
    void setName(const QString &name)
    {
        mName = name;
    }

private:
    QString mName;

signals:
    void nameChanged(QString name);
};

class WorkspaceModel:public QObject
{
    Q_OBJECT

public:
    WorkspaceModel(QObject *parent = nullptr);

public slots:
    Q_INVOKABLE QJsonArray listJson();
    Q_INVOKABLE void addJson(QJsonValue json);
    Q_INVOKABLE void remove(int index);

private:
    QSettings *settings;
};

#endif // WORKSPACE_H
