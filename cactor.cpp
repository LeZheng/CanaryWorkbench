#include "cactor.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariant>

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


CActor *CActorFactory::create(const QString &json, QObject *parent)
{
    auto jsonDoc = QJsonDocument::fromJson(json.toLocal8Bit());
    if (jsonDoc.isObject()) {
        auto actor = new CActor(parent);
        auto jsonObj = jsonDoc.object();
        auto typeValue = jsonObj["type"];
        if(typeValue.isUndefined()) {
            return actor;
        } else {
            auto metaObj = actor->metaObject();
            foreach (auto key, jsonObj.keys()) {
                if (metaObj->indexOfProperty(key.toStdString().data()) >= 0) {
                    actor->setProperty(key.toStdString().data(), jsonObj[key].toVariant());
                }
            }

            //TODO create actor
            return actor;
        }
    } else {
//TODO error
    }

    return nullptr;
}

CActorGroup::CActorGroup(QObject *parent) : QObject(parent) {}

ActorModel::ActorModel(QObject *parent)
{
    this->settings = new QSettings("Actor Settings", QSettings::IniFormat, this);
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
