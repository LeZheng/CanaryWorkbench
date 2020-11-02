#ifndef WORKSPACE_H
#define WORKSPACE_H

#include <QObject>
#include <QJsonArray>
#include <QSettings>
#include <QQmlListProperty>
#include "cactor.h"


class Pipe : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString inputId READ inputId WRITE setInputId NOTIFY inputIdChanged)
    Q_PROPERTY(QString outputId READ outputId WRITE setOutputId NOTIFY outputIdChanged)
public:
    explicit Pipe(QObject *parent = nullptr);

    void setInputId(const QString &id)
    {
        mInputId = id;
        emit inputIdChanged(mInputId);
    }
    QString inputId()
    {
        return mInputId;
    }
    void setOutputId(const QString &id)
    {
        mOutputId = id;
        emit outputIdChanged(mOutputId);
    }
    QString outputId()
    {
        return mOutputId;
    }

private:
    QString mInputId;
    QString mOutputId;

signals:
    void inputIdChanged(QString inputId);
    void outputIdChanged(QString inputId);
};

class ActorDevice : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString actorId READ actorId WRITE setActorId NOTIFY actorIdChanged)
public:
    explicit ActorDevice(QObject *parent = nullptr);

    void setId(const QString &id)
    {
        this->mId = id;
        emit idChanged(mId);
    }
    QString id() { return mId; }

    void setActorId(const QString &id)
    {
        this->mActorId = id;
        emit actorIdChanged(mActorId);
    }
    QString actorId() { return mActorId; }

public slots:
    QStringList getSlots();
    QStringList getSignals();

private:
    QString mId;
    QString mActorId;

signals:
    void idChanged(QString id);
    void actorIdChanged(QString actorId);
};

class Workspace:public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QQmlListProperty<Pipe> pipeList READ pipeList)
    Q_PROPERTY(QQmlListProperty<ActorDevice> actorList READ actorList)
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
    QQmlListProperty<Pipe> pipeList();

    QQmlListProperty<ActorDevice> actorList();

    void appendPipe(Pipe *pipe);
    int pipeCount() const;
    Pipe *pipeAt(int idx) const;
    void clearPipes();

    void appendActor(ActorDevice *actor);
    int actorCount() const;
    ActorDevice *actorAt(int idx) const;
    void clearActors();

private:
    QString mName;
    QList<Pipe *> mPipeList;
    QList<ActorDevice *> mActorList;

    static void appendPipe(QQmlListProperty<Pipe> *, Pipe *pipe);
    static int pipeCount(QQmlListProperty<Pipe> *);
    static Pipe *pipeAt(QQmlListProperty<Pipe> *,int idx);
    static void clearPipes(QQmlListProperty<Pipe> *);

    static void appendActor(QQmlListProperty<ActorDevice> *, ActorDevice *actor);
    static int actorCount(QQmlListProperty<ActorDevice> *);
    static ActorDevice *actorAt(QQmlListProperty<ActorDevice> *,int idx);
    static void clearActors(QQmlListProperty<ActorDevice> *);
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
