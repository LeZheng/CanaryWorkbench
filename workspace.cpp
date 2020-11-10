#include "workspace.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaMethod>
#include <QDebug>

Workspace::Workspace(const QString &name,QObject *parent):QObject(parent),mName(name)
{
    this->mSetting = new QSettings(mName, QSettings::IniFormat, this);
}

Workspace* Workspace::fromJson(const QString &jsonStr)
{
    auto jsonDoc = QJsonDocument::fromJson(jsonStr.toUtf8());
    if(jsonDoc.isObject()) {
        auto jsonObj = jsonDoc.object();
        auto w = new Workspace(jsonObj.value("name").toString());
        //TODO other property
        return w;
    }
    return nullptr;
}

QQmlListProperty<Pipe> Workspace::pipeList()
{
    return QQmlListProperty<Pipe>(this,
                                  this,
                                  &Workspace::appendPipe,
                                  &Workspace::pipeCount,
                                  &Workspace::pipeAt,
                                  &Workspace::clearPipes);
}

QQmlListProperty<ActorItem> Workspace::actorList()
{
    return QQmlListProperty<ActorItem>(this,
                                  this,
                                  &Workspace::appendActor,
                                  &Workspace::actorCount,
                                  &Workspace::actorAt,
                                  &Workspace::clearActors);
}

void Workspace::appendPipe(Pipe *pipe)
{
    mPipeList.append(pipe);
}

int Workspace::pipeCount() const
{
    return mPipeList.count();
}

Pipe *Workspace::pipeAt(int idx) const
{
    return mPipeList.at(idx);
}

void Workspace::clearPipes()
{
    mPipeList.clear();
}

void Workspace::appendActor(ActorItem *actor)
{
    mActorList.append(actor);
}

int Workspace::actorCount() const
{
    return mActorList.count();
}

ActorItem *Workspace::actorAt(int idx) const
{
    return mActorList.at(idx);
}

void Workspace::clearActors()
{
    mActorList.clear();
}

void Workspace::appendPipe(QQmlListProperty<Pipe> *list, Pipe *pipe)
{
    reinterpret_cast<Workspace *>(list->data)->appendPipe(pipe);
}

int Workspace::pipeCount(QQmlListProperty<Pipe> *list)
{
    return reinterpret_cast<Workspace *>(list->data)->pipeCount();
}

Pipe *Workspace::pipeAt(QQmlListProperty<Pipe> *list, int idx)
{
    return reinterpret_cast<Workspace *>(list->data)->pipeAt(idx);
}

void Workspace::clearPipes(QQmlListProperty<Pipe> *list)
{
    reinterpret_cast<Workspace *>(list->data)->clearPipes();
}

void Workspace::appendActor(QQmlListProperty<ActorItem> *list, ActorItem *actor)
{
    reinterpret_cast<Workspace *>(list->data)->appendActor(actor);
}

int Workspace::actorCount(QQmlListProperty<ActorItem> *list)
{
    return reinterpret_cast<Workspace *>(list->data)->actorCount();
}

ActorItem *Workspace::actorAt(QQmlListProperty<ActorItem> *list, int idx)
{
    return reinterpret_cast<Workspace *>(list->data)->actorAt(idx);
}

void Workspace::clearActors(QQmlListProperty<ActorItem> *list)
{
    return reinterpret_cast<Workspace *>(list->data)->clearActors();
}

WorkspaceModel::WorkspaceModel(QObject *parent):QObject(parent)
{
    this->settings = new QSettings("Workspace Settings", QSettings::IniFormat, this);
    auto spaceArray = settings->value("space-list").toJsonArray();
    foreach (auto space, spaceArray) {
        auto w = new Workspace(space.toObject().value("name").toString() ,this);
        workspaceList.append(w);
    }
    qDebug() << "init:" << workspaceList.length();
}

QJsonArray WorkspaceModel::listJson()
{
    return settings->value("space-list").toJsonArray();
}

QQmlListProperty<Workspace> WorkspaceModel::list()
{
    return QQmlListProperty<Workspace>(this, workspaceList);
}

void WorkspaceModel::addJson(QJsonValue json)
{
    auto array = settings->value("space-list").toJsonArray();
    array.append(json);
    settings->setValue("space-list", array);
}

void WorkspaceModel::remove(int index)
{
    auto array = settings->value("space-list").toJsonArray();
    array.removeAt(index);
    settings->setValue("space-list", array);
}

Workspace *WorkspaceModel::get(const QString &name)
{
    foreach (auto w, workspaceList) {
        if(w->name() == name){
            return w;
        }
    }
    return nullptr;
}

ActorItem *WorkspaceModel::addActor( Workspace *space, QJsonObject json)
{
    auto actor = new ActorItem(space);
    foreach (auto key , json.keys()) {
        actor->setProperty(key.toStdString().data(), json.value(key));
    }
    return actor;
}

Pipe::Pipe(QObject *parent):QObject(parent)
{

}

ActorItem::ActorItem(QObject *parent) : QObject(parent) {}

QStringList ActorItem::getSlots()
{
    QList<QString> slotList;
    CActor *actor = nullptr; //TODO get from ActorModel;
    if (actor) {
        auto mObject = actor->metaObject();
        for (int i = 0; i < mObject->methodCount(); i++) {
            auto method = mObject->method(i);
            if (method.methodType() == QMetaMethod::Slot && method.access() == QMetaMethod::Public) {
                slotList.append(method.name());
            }
        }
    }
    return slotList;
}

QStringList ActorItem::getSignals()
{
    QList<QString> signalList;
    CActor *actor = nullptr; //TODO get from ActorModel;
    if (actor) {
        auto mObject = actor->metaObject();
        for (int i = 0; i < mObject->methodCount(); i++) {
            auto method = mObject->method(i);
            if (method.methodType() == QMetaMethod::Signal && method.access() == QMetaMethod::Public) {
                signalList.append(method.name());
            }
        }
    }
    return signalList;
}
