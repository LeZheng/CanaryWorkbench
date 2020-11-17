#include "cactor.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariant>
#include <QMetaObject>
#include <QMetaMethod>

CActor::CActor(QObject *parent) : QObject(parent)
{

}

CActor *CActor::create(const QString &json, QObject *parent)
{
    auto actor = new CActor(parent);
    //TODO
    auto metaObj = actor->metaObject();
    auto jsonDoc = QJsonDocument::fromJson(json.toLocal8Bit());
    if (jsonDoc.isObject()) {
        auto jsonObj = jsonDoc.object();
        foreach (auto key, jsonObj.keys()) {
            if (metaObj->indexOfProperty(key.toStdString().data()) >= 0) {
                actor->setProperty(key.toStdString().data(), jsonObj[key].toVariant());
            }
        }
    }

    return actor;
}

QStringList CActor::getSignals()
{
    QStringList signalList;
    for(int i = 0;i < metaObject()->methodCount();i++){
        auto method = metaObject()->method(i);
        if(method.methodType() == QMetaMethod::Signal){
            signalList.append(method.name());
        }
    }
    return signalList;
}

QStringList CActor::getSlots()
{
    QStringList slotList;
    for(int i = 0;i < metaObject()->methodCount();i++){
        auto method = metaObject()->method(i);
        if(method.methodType() == QMetaMethod::Slot){
            slotList.append(method.name());
        }
    }
    return slotList;
}


CActor *CActorFactory::create(const QString &json, QObject *parent)
{
    auto jsonDoc = QJsonDocument::fromJson(json.toLocal8Bit());
    if (jsonDoc.isObject()) {
        return create(jsonDoc.object(), parent);
    } else {
//TODO error
    }

    return nullptr;
}

CActor *CActorFactory::create(const QJsonObject &jsonObj, QObject *parent)
{
    if (jsonObj.isEmpty()) {
        return nullptr;
    } else {
        auto typeValue = jsonObj["type"];
        if (typeValue.isUndefined()) {
            return nullptr;
        } else {
            auto actor = newActor(typeValue.toString(),parent);
            auto metaObj = actor->metaObject();
            foreach (auto key, jsonObj.keys()) {
                if (metaObj->indexOfProperty(key.toStdString().data()) >= 0) {
                    actor->setProperty(key.toStdString().data(), jsonObj[key].toVariant());
                }
            }
            return actor;
        }
    }
}

CActor *CActorFactory::newActor(const QString &type, QObject *parent)
{
    if (type == "cmd") {//TODO use map
        return new CmdActor(parent);
    } else {
        return new CActor(parent);
    }
}

CActorGroup::CActorGroup(QObject *parent) : QObject(parent) {}

ActorModel::ActorModel(QObject *parent)
{
    this->settings = new QSettings("Actor Settings", QSettings::IniFormat, this);
    auto actorArray = this->settings->value("actor-list").toJsonArray();
    foreach (auto actorValue, actorArray) {
        auto actor = CActorFactory::create(actorValue.toObject());
        if (actor) {
            actorMap.insert(actor->id(), actor);
        }
    }
}

CActor *ActorModel::getActor(const QString &id)
{
    return actorMap.value(id, nullptr);
}

QJsonArray ActorModel::listGroupJson()
{
    return this->settings->value("group-list").toJsonArray();
}

void ActorModel::addGroupJson(QJsonValue json)
{
    auto array = settings->value("group-list").toJsonArray();
    array.append(json);
    settings->setValue("group-list", array);
}

void ActorModel::removeGroup(int index)
{
    auto array = settings->value("group-list").toJsonArray();
    array.removeAt(index);
    settings->setValue("group-list", array);
}

void ActorModel::addActor(QJsonObject json)
{
    auto actor = CActorFactory::create(json, this);
    if (actor) {
        actorMap.insert(actor->name(), actor);
        auto actorArray = this->settings->value("actor-list").toJsonArray();
        actorArray.append(json);
        this->settings->setValue("actor-list", actorArray);
    }
}

QJsonArray ActorModel::getGroupActors(QString group)
{
    QJsonArray array;
    auto actorArray = this->settings->value("actor-list").toJsonArray();
    foreach (auto actor, actorArray) {
        if (actor.toObject().value("group").toString() == group) {
            array.append(actor);
        }
    }
    return array;
}

void ActorModel::removeActor(QString name)
{
    auto actor = actorMap.take(name);
    if (actor) {
        actor->deleteLater();
    }
    auto actorArray = this->settings->value("actor-list").toJsonArray();
    for (int i = 0; i < actorArray.size(); i++) {
        if (name == actorArray.at(i).toObject().value("name").toString()) {
            actorArray.removeAt(i);
            break;
        }
    }
    this->settings->setValue("actor-list", actorArray);
}

void ActorModel::removeActors(QString groupName)
{
    auto actorArray = this->settings->value("actor-list").toJsonArray();
    QJsonArray newArray;
    foreach (auto actor, actorArray) {
        if (actor.toObject().value("group") != groupName) {
            newArray.append(actor);
        } else {
            auto a = actorMap.take(actor.toObject().value("name").toString());
            a->deleteLater();
        }
    }
    this->settings->setValue("actor-list", newArray);
}

CmdActor::CmdActor(QObject *parent):CActor(parent)
{

}

void CmdActor::start()
{
    this->process = new QProcess(this);
    this->process->start(mCmd);

    connect(this->process, &QProcess::readyRead, this, [this]() {
        QString msg(this->process->readAll());
        emit received(msg);
    });

    connect(this->process, &QProcess::stateChanged, this, [this](QProcess::ProcessState newState) {
        //TODO
    });

    connect(this->process, &QProcess::errorOccurred, this, [this](QProcess::ProcessError error) {
        //TODO
    });
}

void CmdActor::stop()
{
    if (this->process && this->process->state() != QProcess::NotRunning) {
        this->process->kill();
        this->process->deleteLater();
        this->process = nullptr;
    }
}

void CmdActor::send(const QString &msg)
{
    if (this->process && this->process->state() == QProcess::Running) {
        this->process->write(msg.toUtf8());
    }
}
