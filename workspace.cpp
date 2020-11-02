#include "workspace.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaMethod>

Workspace::Workspace(QObject *parent):QObject(parent)
{

}

Workspace* Workspace::fromJson(const QString &jsonStr)
{
    auto w = new Workspace();
    auto jsonDoc = QJsonDocument::fromJson(jsonStr.toUtf8());
    if(jsonDoc.isObject()) {
        auto jsonObj = jsonDoc.object();
        w->setName(jsonObj.value("name").toString());
        //TODO other property
    }
    return w;
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

QQmlListProperty<ActorDevice> Workspace::actorList()
{
    return QQmlListProperty<ActorDevice>(this,
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

void Workspace::appendActor(ActorDevice *actor)
{
    mActorList.append(actor);
}

int Workspace::actorCount() const
{
    return mActorList.count();
}

ActorDevice *Workspace::actorAt(int idx) const
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

void Workspace::appendActor(QQmlListProperty<ActorDevice> *list, ActorDevice *actor)
{
    reinterpret_cast<Workspace *>(list->data)->appendActor(actor);
}

int Workspace::actorCount(QQmlListProperty<ActorDevice> *list)
{
    return reinterpret_cast<Workspace *>(list->data)->actorCount();
}

ActorDevice *Workspace::actorAt(QQmlListProperty<ActorDevice> *list, int idx)
{
    return reinterpret_cast<Workspace *>(list->data)->actorAt(idx);
}

void Workspace::clearActors(QQmlListProperty<ActorDevice> *list)
{
    return reinterpret_cast<Workspace *>(list->data)->clearActors();
}

WorkspaceModel::WorkspaceModel(QObject *parent):QObject(parent)
{
    this->settings = new QSettings("Workspace Settings", QSettings::IniFormat, this);
}

QJsonArray WorkspaceModel::listJson()
{
    return settings->value("space-list").toJsonArray();
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

Pipe::Pipe(QObject *parent):QObject(parent)
{

}

ActorDevice::ActorDevice(QObject *parent) : QObject(parent) {}

QStringList ActorDevice::getSlots()
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

QStringList ActorDevice::getSignals()
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
