#include "workspace.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaMethod>
#include <QDebug>
#include <cactor.h>
#include <QMessageBox>
#include "utils.h"

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
    return QQmlListProperty<Pipe>(this,mPipeList);
}

QQmlListProperty<ActorItem> Workspace::actorList()
{
    return QQmlListProperty<ActorItem>(this,mActorList);
}

QJsonObject Workspace::toJson()
{
    QJsonObject spaceJson;
    spaceJson.insert("id", id());
    spaceJson.insert("name", name());
    QJsonArray actorArray;
    foreach (auto actor, mActorList) {
        QJsonObject actorJson;
        actorJson.insert("id", actor->id());
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
    foreach (auto pipe, mPipeList) {
        QJsonObject pipeJson;
        pipeJson.insert("id", pipe->id());
        pipeJson.insert("inputId", pipe->inputId());
        pipeJson.insert("outputId", pipe->outputId());
        pipeJson.insert("signalName", pipe->signalName());
        pipeJson.insert("slotName", pipe->slotName());
        pipeArray.append(pipeJson);
    }
    spaceJson.insert("pipeList", pipeArray);
    return spaceJson;
}

WorkspaceModel::WorkspaceModel(ActorModel *m,QObject *parent):QObject(parent)
{
    this->actorModel = m;
    this->settings = new QSettings("Workspace Settings", QSettings::IniFormat, this);

    //-------------------------------
    if(QSqlDatabase::contains()) {
        db = QSqlDatabase::database();
    } else {
        db = QSqlDatabase::addDatabase("QSQLITE");
    }

    db.setDatabaseName("CanaryData.db");
    if (!db.open()) {
        QMessageBox::critical(nullptr, QObject::tr("Cannot open database"),
                              QObject::tr("Unable to establish a database connection.\n"
                                          "This example needs SQLite support. Please read "
                                          "the Qt SQL driver documentation for information how "
                                          "to build it.\n\n"
                                          "Click Cancel to exit."), QMessageBox::Cancel);
        qWarning() << "Cannot open database";
        return;
    }

    QStringList tables = db.tables();
    if(!tables.contains("c_workspace")) {
        QSqlQuery q(db);
        bool r = q.exec("CREATE TABLE c_workspace ("
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                        "name TEXT "
                        ")");
        qDebug() << r << " - " << q.lastError();
    }
    spaceModel = new QSqlTableModel(this, db);
    spaceModel->setTable("c_workspace");
    spaceModel->setEditStrategy(QSqlTableModel::OnManualSubmit);
    spaceModel->select();

    if(!tables.contains("c_pipe_item")) {
        QSqlQuery q(db);
        bool r = q.exec("CREATE TABLE c_pipe_item ("
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                        "spaceId TEXT, "
                        "inputId TEXT, "
                        "outputId Text, "
                        "signalName Text, "
                        "slotName Text "
                        ")");
        qDebug() << r << " - " << q.lastError();
    }
    pipeItemModel = new QSqlTableModel(this, db);
    pipeItemModel->setTable("c_pipe_item");
    pipeItemModel->setEditStrategy(QSqlTableModel::OnManualSubmit);
    pipeItemModel->select();

    if(!tables.contains("c_actor_item")) {
        QSqlQuery q(db);
        bool r = q.exec("CREATE TABLE c_actor_item ("
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                        "spaceId TEXT, "
                        "actorId TEXT, "
                        "x INTEGER, "
                        "y INTEGER, "
                        "width INTEGER, "
                        "height INTEGER "
                        ")");
        qDebug() << r << " - " << q.lastError();
    }
    actorItemModel = new QSqlTableModel(this, db);
    actorItemModel->setTable("c_actor_item");
    actorItemModel->setEditStrategy(QSqlTableModel::OnManualSubmit);
    actorItemModel->select();
}

QJsonArray WorkspaceModel::listJson()
{
    QJsonArray array;
    for(int i = 0; i < spaceModel->rowCount(); i++) {
        auto r = spaceModel->record(i);
        array.append(QJsonObject{
            {"id", r.value("id").toString()},
            {"name", r.value("name").toString()}
        });
    }

    return array;
}

QJsonValue WorkspaceModel::addJson(QJsonValue json)
{
    QSqlRecord r;
    QSqlField idField("id", QVariant::Int);
    idField.setAutoValue(true);
    idField.setGenerated(true);
    QSqlField nameField("name", QVariant::String);
    auto name = json.toObject().value("name").toString();
    nameField.setValue(name);
    r.append(idField);
    r.append(nameField);
    spaceModel->insertRecord(-1, r);
    spaceModel->submitAll();

    QSqlRecord record = spaceModel->record(spaceModel->rowCount() - 1);
    auto w = new Workspace(name, this);
    w->setId(record.value("id").toString());
    workspaceMap.insert(w->id(), w);

    return w->toJson();
}

void WorkspaceModel::remove(const QString &id)
{
    auto w = workspaceMap.take(id);
    if(w) {
        w->deleteLater();
    }

    db.transaction();
    for(int i = 0; i < spaceModel->rowCount(); i++) {
        if(spaceModel->record(i).value("id").toString() == id) {
            spaceModel->removeRow(i);
            spaceModel->submitAll();
            break;
        }
    }

    for(int i = 0; i < pipeItemModel->rowCount(); i++) {
        if(pipeItemModel->record(i).value("spaceId").toString() == id) {
            pipeItemModel->removeRow(i);
        }
    }
    pipeItemModel->submitAll();

    for(int i = 0; i < actorItemModel->rowCount(); i++) {
        if(actorItemModel->record(i).value("spaceId").toString() == id) {
            actorItemModel->removeRow(i);
        }
    }
    actorItemModel->submitAll();
    db.commit();
}

Workspace *WorkspaceModel::get(const QString &id)
{
    auto w = workspaceMap.value(id, nullptr);
    if(w != nullptr) {
        return w;
    } else {
        QSqlQuery q(db);
        q.prepare("SELECT * FROM c_workspace WHERE id=?");
        q.bindValue(0, id);
        q.exec();
        q.next();
        auto r = q.record();
        if(!r.isEmpty()) {
            w = new Workspace(r.value("name").toString(), this);
            w->setId(r.value("id").toString());
            workspaceMap.insert(id, w);
            return w;
        } else {
            return nullptr;
        }
    }
}

ActorItem *WorkspaceModel::addActor( Workspace *space, QJsonObject json)
{
    auto actor = new ActorItem(space);
    foreach (auto key, json.keys()) {
        actor->setProperty(key.toStdString().data(), json.value(key));
    }
    actor->setSpaceId(space->id());
    auto a = actorModel->getActor(actor->actorId());
    if (a) {
        actor->setImpl(a->clone(actor));
    }
//    space->appendActor(actor);TODO

    actorItemModel->insertRecord(-1, actor->toRecord());
    actorItemModel->submitAll();

    return actor;
}

Pipe *WorkspaceModel::addPipe(Workspace *space, QJsonObject json)
{
    auto pipe = new Pipe(space);
    foreach (auto key, json.keys()) {
        pipe->setProperty(key.toStdString().data(), json.value(key));
    }
    pipe->setSpaceId(space->id());
//    space->appendPipe(pipe);TODO

    pipeItemModel->insertRecord(-1, pipe->toRecord());
    pipeItemModel->submitAll();
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

QJsonArray WorkspaceModel::getPipeList(const QString &spaceId)
{
    QJsonArray list;
    QSqlQuery q(db);
    q.prepare("SELECT * FROM c_pipe_item WHERE spaceId=?");
    q.bindValue(0, spaceId);
    q.exec();
    while(q.next()) {
        auto r = q.record();
        list.append(QJsonObject{
            {"id", r.value("id").toString()},
            {"spaceId", r.value("spaceId").toString()},
            {"inputId", r.value("inputId").toString()},
            {"outputId", r.value("outputId").toString()},
            {"signalName", r.value("signalName").toString()},
            {"slotName", r.value("slotName").toString()}
        });
    }

    return list;
}

QJsonArray WorkspaceModel::getActorList(const QString &spaceId)
{
    QJsonArray list;
    QSqlQuery q(db);
    q.prepare("SELECT * FROM c_actor_item WHERE spaceId=?");
    q.bindValue(0, spaceId);
    q.exec();
    while(q.next()) {
        auto r = q.record();
        list.append(QJsonObject{
            {"id", r.value("id").toString()},
            {"spaceId", r.value("spaceId").toString()},
            {"actorId", r.value("actorId").toString()},
            {"x", r.value("x").toString()},
            {"y", r.value("y").toString()},
            {"width", r.value("width").toString()},
            {"height", r.value("height").toString()}
        });
    }

    return list;
}

Pipe *WorkspaceModel::getPipe(const QString &id)
{
    QSqlQuery q(db);
    q.prepare("SELECT * FROM c_pipe_item WHERE id=?");
    q.bindValue(0, id);
    q.exec();
    if(q.next()) {
        auto r = q.record();
        auto p = new Pipe(this);
        for(int i= 0; i < r.count(); i++) {
            auto field = r.field(i);
            p->setProperty(field.name().toUtf8(), field.value());
        }
        return p;
    } else {
        return nullptr;
    }
}

ActorItem *WorkspaceModel::getActor(const QString &id)
{
    QSqlQuery q(db);
    q.prepare("SELECT * FROM c_actor_item WHERE id=?");
    q.bindValue(0, id);
    q.exec();
    if(q.next()) {
        auto r = q.record();
        auto a = new ActorItem(this);
        for(int i= 0; i < r.count(); i++) {
            auto field = r.field(i);
            a->setProperty(field.name().toUtf8(), field.value());
        }
        auto actor = actorModel->getActor(a->actorId());
        if (actor) {
            a->setImpl(actor->clone(a));
        }
        return a;
    } else {
        return nullptr;
    }
}

Pipe::Pipe(QObject *parent):QObject(parent)
{

}

QSqlRecord Pipe::toRecord()
{
    QSqlRecord r;
    r.append(field("id",QVariant::Int, id()));
    r.append(field("spaceId",QVariant::String, spaceId()));
    r.append(field("inputId",QVariant::String, inputId()));
    r.append(field("outputId",QVariant::String, outputId()));
    r.append(field("slotName",QVariant::String, slotName()));
    r.append(field("signalName",QVariant::String, signalName()));
    return r;
}

ActorItem::ActorItem(QObject *parent) : QObject(parent) {}

QSqlRecord ActorItem::toRecord()
{
    QSqlRecord r;
    r.append(field("id", QVariant::Int, id()));
    r.append(field("spaceId", QVariant::String, spaceId()));
    r.append(field("actorId", QVariant::String, actorId()));
    r.append(field("x", QVariant::Int, x()));
    r.append(field("y", QVariant::Int, y()));
    r.append(field("height", QVariant::Int, height()));
    r.append(field("width", QVariant::Int, width()));
    return r;
}
