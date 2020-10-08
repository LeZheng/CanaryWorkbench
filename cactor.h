#ifndef CACTOR_H
#define CACTOR_H

#include <QObject>
#include <QThread>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>

class CActor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)


public:
    explicit CActor(QObject *parent = nullptr);

    static CActor *create(const QString &json, QObject *parent = nullptr);

    QString id()
    {
        return mId;
    }

    void setId(const QString &id)
    {
        this->mId = id;
        emit idChanged(mId);
    }

    QString type()
    {
        return mType;
    }

    void setType(const QString &type)
    {
        this->mType = type;
        emit typeChanged(mType);
    }

    QString group()
    {
        return mGroup;
    }

    void setGroup(const QString &group)
    {
        this->mGroup = group;
        emit groupChanged(mGroup);
    }

    QString name()
    {
        return mName;
    }

    void setName(const QString &name)
    {
        this->mName = name;
        emit nameChanged(name);
    }

private:
    QString mId;
    QString mType;
    QString mGroup;
    QString mName;

signals:
    void idChanged(QString id);
    void typeChanged(QString type);
    void groupChanged(QString group);
    void nameChanged(QString name);
};

class CActorGroup : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

public:
    explicit CActorGroup(QObject *parent = nullptr);

    QString name()
    {
        return mName;
    }
    void setName(const QString &name)
    {
        this->mName = name;
        emit nameChanged(this->mName);
    }

private:
    QString mName;

signals:
    void nameChanged(QString name);
};

class ActorModel : public QObject
{
    Q_OBJECT

public:
    explicit ActorModel(QObject *parent = nullptr);
public slots:
    Q_INVOKABLE QJsonArray listGroupJson();
    Q_INVOKABLE void addGroupJson(QJsonValue json);
    Q_INVOKABLE void removeGroup(int index);
private:
    QSettings *settings;
};

class CActorFactory
{
public:
    static CActor* create(const QString &json, QObject *parent = nullptr);
};

class CmdActor : public CActor
{
private:
    QString cmd;
};

class FunctionActor : public CActor
{

};

#endif // CACTOR_H
