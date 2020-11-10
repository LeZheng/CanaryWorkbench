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

class ActorItem : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString actorId READ actorId WRITE setActorId NOTIFY actorIdChanged)
    Q_PROPERTY(int x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(int y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(int width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)
public:
    explicit ActorItem(QObject *parent = nullptr);

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

    void setX(int x){
        this->mX = x;
        emit xChanged(mX);
    }
    int x(){
        return mX;
    }
    void setY(int y){
        this->mY = y;
        emit yChanged(mY);
    }
    int y(){
        return mY;
    }

    void setHeight(int height){
        this->mHeight = height;
        emit heightChanged(mHeight);
    }
    int height(){
        return mHeight;
    }

    void setWidth(int width){
        this->mWidth = width;
        emit widthChanged(mWidth);
    }

    int width(){
        return mWidth;
    }

public slots:
    QStringList getSlots();
    QStringList getSignals();

private:
    QString mId;
    QString mActorId;
    int mX;
    int mY;
    int mWidth;
    int mHeight;

signals:
    void idChanged(QString id);
    void actorIdChanged(QString actorId);
    void xChanged(int x);
    void yChanged(int y);
    void widthChanged(int width);
    void heightChanged(int height);
};

class Workspace:public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QQmlListProperty<Pipe> pipeList READ pipeList)
    Q_PROPERTY(QQmlListProperty<ActorItem> actorList READ actorList)
public:
    Workspace(const QString &name,QObject *parent = nullptr);

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

    QQmlListProperty<ActorItem> actorList();

    void appendPipe(Pipe *pipe);
    int pipeCount() const;
    Pipe *pipeAt(int idx) const;
    void clearPipes();

    void appendActor(ActorItem *actor);
    int actorCount() const;
    ActorItem *actorAt(int idx) const;
    void clearActors();

private:
    QString mName;
    QList<Pipe *> mPipeList;
    QList<ActorItem *> mActorList;
    QSettings *mSetting;

    static void appendPipe(QQmlListProperty<Pipe> *, Pipe *pipe);
    static int pipeCount(QQmlListProperty<Pipe> *);
    static Pipe *pipeAt(QQmlListProperty<Pipe> *,int idx);
    static void clearPipes(QQmlListProperty<Pipe> *);

    static void appendActor(QQmlListProperty<ActorItem> *, ActorItem *actor);
    static int actorCount(QQmlListProperty<ActorItem> *);
    static ActorItem *actorAt(QQmlListProperty<ActorItem> *,int idx);
    static void clearActors(QQmlListProperty<ActorItem> *);
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
    Q_INVOKABLE QQmlListProperty<Workspace> list();
    Q_INVOKABLE void addJson(QJsonValue json);
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE Workspace* get(const QString &name);
    Q_INVOKABLE ActorItem* addActor( Workspace *space,QJsonObject json);

private:
    QSettings *settings;
    QList<Workspace *> workspaceList;
};

#endif // WORKSPACE_H
