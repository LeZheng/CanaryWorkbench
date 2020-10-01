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
