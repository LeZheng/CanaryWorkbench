#ifndef CACTOR_H
#define CACTOR_H

#include <QObject>
#include <QThread>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QQmlListProperty>
#include <QProcess>

class CActor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString form READ form WRITE setForm NOTIFY formChanged)


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

    QString form() { return mForm; }

    void setForm(const QString &form)
    {
        this->mForm = form;
        emit formChanged(mForm);
    }

private:
    QString mId;
    QString mType;
    QString mGroup;
    QString mName;
    QString mForm;

signals:
    void idChanged(QString id);
    void typeChanged(QString type);
    void groupChanged(QString group);
    void nameChanged(QString name);
    void formChanged(QString form);
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

    CActor *getActor(const QString &id);
public slots:
    Q_INVOKABLE QJsonArray listGroupJson();
    Q_INVOKABLE void addGroupJson(QJsonValue json);
    Q_INVOKABLE void removeGroup(int index);
    Q_INVOKABLE void addActor(QJsonObject json);
    Q_INVOKABLE QJsonArray getGroupActors(QString group);
    Q_INVOKABLE void removeActor(QString name);
    Q_INVOKABLE void removeActors(QString groupName);
private:
    QSettings *settings;
    QMap<QString, CActor *> actorMap;
};

class CActorFactory
{
public:
    static CActor* create(const QString &json, QObject *parent = nullptr);
    static CActor* create(const QJsonObject &json, QObject *parent = nullptr);

private:
    static CActor *newActor(const QString &type, QObject *parent = nullptr);
};

class CmdActor : public CActor
{
    Q_OBJECT

    Q_PROPERTY(QString cmd READ cmd WRITE setCmd NOTIFY cmdChanged)
public:
    explicit CmdActor(QObject *parent = nullptr);

    void setCmd(const QString &cmd)
    {
        this->mCmd = cmd;
        emit cmdChanged(mCmd);
    }
    QString cmd()
    {
        return mCmd;
    }

private:
    QString mCmd;
    QProcess *process;


public slots:
    void start();
    void stop();
    void send(const QString &msg);
signals:
    void cmdChanged(QString cmd);
    void received(QString msg);
};

class FunctionActor : public CActor
{

};

#endif // CACTOR_H
