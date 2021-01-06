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

#include <QtSql>

class CActor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString groupId READ groupId WRITE setGroupId NOTIFY groupIdChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString form READ form WRITE setForm NOTIFY formChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(QString data READ data WRITE setData NOTIFY dataChanged)


public:
    explicit CActor( QObject *parent = nullptr);

    static CActor *create(const QString &json, QObject *parent = nullptr);

    Q_INVOKABLE QStringList getSignals();

    Q_INVOKABLE QStringList getSlots();

    Q_INVOKABLE QJsonArray getSlotList();

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

    QString groupId()
    {
        return mGroup;
    }

    void setGroupId(const QString &group)
    {
        this->mGroup = group;
        emit groupIdChanged(mGroup);
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

    QString form()
    {
        return mForm;
    }

    void setForm(const QString &form)
    {
        this->mForm = form;
        emit formChanged(mForm);
    }

    QString description()
    {
        return mDesc;
    }

    void setDescription(const QString &desc)
    {
        this->mDesc = desc;
        emit descriptionChanged(mDesc);
    }

    QString state()
    {
        return mState;
    }

    void setState(const QString &s)
    {
        this->mState = s;
        emit stateChanged(mState);
    }

    QString data()
    {
        return mData;
    }

    void setData(const QString &d)
    {
        this->mData = d;
        emit dataChanged(d);
    }

    CActor *clone(QObject *parent = nullptr);

private:
    QString mId;
    QString mType;
    QString mGroup;
    QString mName;
    QString mForm;
    QString mDesc;
    QString mState;
    QString mData;

signals:
    void idChanged(QString id);
    void typeChanged(QString type);
    void groupIdChanged(QString group);
    void nameChanged(QString name);
    void formChanged(QString form);
    void descriptionChanged(QString desc);
    void stateChanged(QString state);
    void dataChanged(QString data);
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
    Q_INVOKABLE QJsonObject addGroupJson(QJsonValue json);
    Q_INVOKABLE void removeGroup(int index);
    Q_INVOKABLE void addActor(QJsonObject json);
    Q_INVOKABLE QJsonArray getGroupActors(QString group);
    Q_INVOKABLE CActor* getActor(const QString &id);
    Q_INVOKABLE void removeActor(QString name);
    Q_INVOKABLE void removeActors(QString groupName);
private:
    QMap<QString, CActor *> actorMap;
    QSqlDatabase db;
    QSqlTableModel *actorModel;
    QSqlTableModel *groupModel;
};

class CActorFactory
{
public:
    static CActor* create(const QString &json, QObject *parent = nullptr);
    static CActor* create(const QJsonObject &json, QObject *parent = nullptr);
    static CActor* create(const QSqlRecord &record, QObject *parent = nullptr);
private:
    static CActor *newActor(const QString &type, QObject *parent = nullptr);
};

class CmdActor : public CActor
{
    Q_OBJECT

public:
    Q_INVOKABLE explicit CmdActor(QObject *parent = nullptr);

private:
    QProcess *process = nullptr;


public slots:
    void start(QStringList args);
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
