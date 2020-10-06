#include "workspace.h"
#include <QJsonDocument>
#include <QJsonObject>

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
