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

QJsonObject Workspace::toJson()
{
    QJsonObject spaceJson;
    spaceJson.insert("name", name());
    QJsonArray actorArray;
    foreach (auto actor , mActorList) {
        QJsonObject actorJson;
        actorJson.insert("x", actor->x());
        actorJson.insert("y", actor->y());
        actorJson.insert("width", actor->width());
        actorJson.insert("height", actor->height());
        actorJson.insert("id", actor->id());
        actorJson.insert("actorId", actor->actorId());
        actorArray.append(actorJson);
    }
    spaceJson.insert("actorList", actorArray);

    QJsonArray pipeArray;
    foreach (auto pipe , mPipeList) {
        QJsonObject pipeJson;
        pipeJson.insert("inputId", pipe->inputId());
        pipeJson.insert("outputId", pipe->outputId());
        pipeJson.insert("signalName", pipe->signalName());
        pipeJson.insert("slotName", pipe->slotName());
        pipeArray.append(pipeJson);
    }
    spaceJson.insert("pipeList", pipeArray);
    return spaceJson;
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
        auto actorArray = space.toObject().value("actorList").toArray();
        foreach (auto actorJson, actorArray) {
            auto actor = new ActorItem(w);
            auto json = actorJson.toObject();
            foreach (auto key , json.keys()) {
                actor->setProperty(key.toStdString().data(), json.value(key));
            }
            w->appendActor(actor);
        }
        auto pipeArray = space.toObject().value("pipeList").toArray();
        foreach (auto pipeJson, pipeArray) {
            auto pipe = new Pipe(w);
            auto json = pipeJson.toObject();
            foreach (auto key , json.keys()) {
                pipe->setProperty(key.toStdString().data(), json.value(key));
            }
            w->appendPipe(pipe);
        }
        workspaceList.append(w);
        workspaceMap.insert(w->name(), w);
    }
    QJsonDocument d(spaceArray);
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
    if(json.isObject()){
        auto spaceJson = json.toObject();
        auto w = new Workspace(spaceJson.value("name").toString(), this);
        workspaceMap.insert(w->name(), w);

        save(spaceJson);
    }
}

void WorkspaceModel::remove(const QString &name)
{
    auto w = workspaceMap.take(name);
    if(w){
        QJsonArray spaceArray;
        foreach (auto space, workspaceMap.values()) {
            auto json = space->toJson();
            spaceArray.append(json);
        }
        w->deleteLater();
        settings->setValue("space-list", spaceArray);
    }
}

Workspace *WorkspaceModel::get(const QString &name)
{
    return workspaceMap.value(name);
}

ActorItem *WorkspaceModel::addActor( Workspace *space, QJsonObject json)
{
    auto actor = new ActorItem(space);
    foreach (auto key , json.keys()) {
        actor->setProperty(key.toStdString().data(), json.value(key));
    }
    space->appendActor(actor);
    return actor;
}

Pipe *WorkspaceModel::addPipe(Workspace *space, QJsonObject json)
{
    auto pipe = new Pipe(space);
    foreach (auto key, json.keys()) {
        pipe->setProperty(key.toStdString().data(), json.value(key));
    }
    space->appendPipe(pipe);
    return pipe;
}

void WorkspaceModel::save(const QJsonObject &json)
{
    QJsonArray spaceArray;
    foreach (auto space, workspaceMap.values()) {
        spaceArray.append(space->toJson());
    }
    settings->setValue("space-list", spaceArray);
}

Pipe::Pipe(QObject *parent):QObject(parent)
{

}

ActorItem::ActorItem(QObject *parent) : QObject(parent) {}
