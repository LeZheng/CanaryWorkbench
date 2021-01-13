#ifndef WORKSPACE_H
#define WORKSPACE_H

#include <QObject>
#include <QJsonArray>
#include <QSettings>
#include <QQmlListProperty>
#include "cactor.h"
#include <QDebug>

#include <QtSql>

class Pipe : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString mId READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString spaceId READ spaceId WRITE setSpaceId NOTIFY spaceIdChanged)
    Q_PROPERTY(QString inputId READ inputId WRITE setInputId NOTIFY inputIdChanged)
    Q_PROPERTY(QString outputId READ outputId WRITE setOutputId NOTIFY outputIdChanged)
    Q_PROPERTY(QString signalName READ signalName WRITE setSignalName NOTIFY signalNameChanged)
    Q_PROPERTY(QString slotName READ slotName WRITE setSlotName NOTIFY slotNameChanged)
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
    void setSignalName(const QString &sName)
    {
        mSignalName = sName;
        emit signalNameChanged(mSignalName);
    }
    QString signalName()
    {
        return mSignalName;
    }
    void setSlotName(const QString &sName)
    {
        mSlotName = sName;
        emit slotNameChanged(mSlotName);
    }
    QString slotName()
    {
        return mSlotName;
    }

    void setId(const QString &id)
    {
        mId = id;
        emit idChanged(mId);
    }
    QString id()
    {
        return mId;
    }

    void setSpaceId(const QString &i)
    {
        mSpaceId = i;
        emit spaceIdChanged(mSpaceId);
    }

    QString spaceId()
    {
        return mSpaceId;
    }

    QSqlRecord toRecord();

private:
    QString mInputId;
    QString mOutputId;
    QString mSignalName;
    QString mSlotName;
    QString mId;
    QString mSpaceId;

signals:
    void inputIdChanged(QString inputId);
    void outputIdChanged(QString inputId);
    void signalNameChanged(QString signalName);
    void slotNameChanged(QString slotName);
    void idChanged(QString id);
    void spaceIdChanged(QString spaceId);
};

class ActorItem : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString spaceId READ spaceId WRITE setSpaceId NOTIFY spaceIdChanged)
    Q_PROPERTY(QString actorId READ actorId WRITE setActorId NOTIFY actorIdChanged)
    Q_PROPERTY(int x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(int y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(int width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)
    Q_PROPERTY(CActor * impl READ impl WRITE setImpl)
public:
    explicit ActorItem(QObject *parent = nullptr);

    void setId(const QString &id)
    {
        this->mId = id;
        emit idChanged(mId);
    }
    QString id()
    {
        return mId;
    }

    void setActorId(const QString &id)
    {
        this->mActorId = id;
        emit actorIdChanged(mActorId);
    }
    QString actorId()
    {
        return mActorId;
    }

    void setX(int x)
    {
        this->mX = x;
        emit xChanged(mX);
    }
    int x()
    {
        return mX;
    }
    void setY(int y)
    {
        this->mY = y;
        emit yChanged(mY);
    }
    int y()
    {
        return mY;
    }

    void setHeight(int height)
    {
        this->mHeight = height;
        emit heightChanged(mHeight);
    }
    int height()
    {
        return mHeight;
    }

    void setWidth(int width)
    {
        this->mWidth = width;
        emit widthChanged(mWidth);
    }

    int width()
    {
        return mWidth;
    }

    void setImpl( CActor *a)
    {
        this->mActor = a;
    }

    CActor *impl()
    {
        return mActor;
    }

    void setSpaceId(const QString &i)
    {
        mSpaceId = i;
        emit spaceIdChanged(mSpaceId);
    }

    QString spaceId()
    {
        return mSpaceId;
    }

    QSqlRecord toRecord();

private:
    QString mId;
    QString mSpaceId;
    QString mActorId;
    int mX;
    int mY;
    int mWidth;
    int mHeight;
    CActor *mActor;

signals:
    void idChanged(QString id);
    void actorIdChanged(QString actorId);
    void xChanged(int x);
    void yChanged(int y);
    void widthChanged(int width);
    void heightChanged(int height);
    void spaceIdChanged(QString spaceId);
};

class Workspace:public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
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
        emit nameChanged(mName);
    }
    QString id()
    {
        return mId;
    }
    void setId(const QString &i)
    {
        mId = i;
        emit idChanged(mId);
    }

    QQmlListProperty<Pipe> pipeList();

    QQmlListProperty<ActorItem> actorList();

    QJsonObject toJson();

private:
    QString mId;
    QString mName;
    QList<Pipe *> mPipeList;
    QList<ActorItem *> mActorList;
    QSettings *mSetting;
signals:
    void nameChanged(QString name);
    void idChanged(QString id);
};

class WorkspaceModel:public QObject
{
    Q_OBJECT

public:
    WorkspaceModel(ActorModel *actorModel, QObject *parent = nullptr);

public slots:
    Q_INVOKABLE QJsonArray listJson();
    Q_INVOKABLE QJsonValue addJson(QJsonValue json);
    Q_INVOKABLE void remove(const QString &name);
    Q_INVOKABLE Workspace* get(const QString &name);
    Q_INVOKABLE ActorItem* addActor( Workspace *space,QJsonObject json);
    Q_INVOKABLE Pipe* addPipe(Workspace *space, QJsonObject json);
    Q_INVOKABLE void save(const QJsonObject &json);
    Q_INVOKABLE QJsonArray getPipeList(const QString &spaceId);
    Q_INVOKABLE QJsonArray getActorList(const QString &spaceId);
    Q_INVOKABLE Pipe * getPipe(const QString &id);
    Q_INVOKABLE ActorItem * getActor(const QString &id);
private:
    QSettings *settings;
    QMap<QString, Workspace*> workspaceMap;
    ActorModel *actorModel;
    QSqlDatabase db;
    QSqlTableModel *spaceModel;
    QSqlTableModel *pipeItemModel;
    QSqlTableModel *actorItemModel;
};

#endif // WORKSPACE_H
