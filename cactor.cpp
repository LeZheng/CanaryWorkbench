#include "cactor.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariant>
#include <QMetaObject>
#include <QMetaMethod>
#include <QDebug>
#include <QMessageBox>

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
    for(int i = 0; i < metaObject()->methodCount(); i++) {
        auto method = metaObject()->method(i);
        if(method.methodType() == QMetaMethod::Signal) {
            signalList.append(method.name());
        }
    }
    return signalList;
}

QStringList CActor::getSlots()
{
    QStringList slotList;
    for(int i = 0; i < metaObject()->methodCount(); i++) {
        auto method = metaObject()->method(i);
        if(method.methodType() == QMetaMethod::Slot) {
            slotList.append(method.name());
        }
    }
    return slotList;
}

QJsonArray CActor::getSlotList()
{
    QJsonArray slotArray;
    auto mObj = metaObject();
    for (int i = 0; i < mObj->methodCount(); i++) {
        auto m = mObj->method(i);
        if (m.methodType() == QMetaMethod::Slot) {
            QString name = m.name();
            QString returnType = m.typeName();
            auto nameList = m.parameterNames();
            auto typeList = m.parameterTypes();
            QJsonArray names;
            for (int j = 0; j < nameList.size(); j++) {
                names.append(QJsonObject{{"name", QString(nameList.at(j))},{"type", QString(typeList.at(j))}});
            }
            slotArray.append( QJsonObject{{"name", name}, {"returnType", returnType}, {"parameters", names}});

        }
    }

    return slotArray;
}

CActor *CActor::clone(QObject *parent)
{
    auto mObj = metaObject();
    auto actor = mObj->newInstance(Q_ARG(QObject *, parent));//TODO null

    for (int i = 0; i < metaObject()->propertyCount(); i++) {
        auto p = metaObject()->property(i);
        auto value = property(p.name());
        actor->setProperty(p.name(), value);
    }

    return static_cast<CActor *>(actor);
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

CActor *CActorFactory::create(const QSqlRecord &record, QObject *parent)
{
    if (record.isEmpty()) {
        return nullptr;
    } else {
        auto typeValue = record.value("type");
        if (!typeValue.isValid() || typeValue.isNull()) {
            return nullptr;
        } else {
            auto actor = newActor(typeValue.toString(),parent);
            auto metaObj = actor->metaObject();
            for(int i = 0; i < record.count(); i++) {
                auto field = record.field(i);
                if (metaObj->indexOfProperty(field.name().toUtf8()) >= 0) {
                    actor->setProperty(field.name().toUtf8(), field.value());
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
    db = QSqlDatabase::addDatabase("QSQLITE");
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
    if(!tables.contains("c_group")) {
        QSqlQuery q(db);
        bool r = q.exec("CREATE TABLE c_group ("
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                        "name TEXT "
                        ")");

        qDebug() << r << " - " << q.lastError();
    }
    groupModel = new QSqlTableModel(this, db);
    groupModel->setTable("c_group");
    groupModel->setEditStrategy(QSqlTableModel::OnManualSubmit);
    groupModel->select();

    if(!tables.contains("c_actor")) {
        QSqlQuery query;
        bool r = query.exec("CREATE TABLE c_actor ("
                            "id INTEGER PRIMARY KEY  AUTOINCREMENT, "
                            "type TEXT, "
                            "groupId TEXT, "
                            "name TEXT, "
                            "form TEXT, "
                            "description TEXT, "
                            "data Text"
                            ")");
        if (query.lastError().isValid())
            qDebug() << query.lastError();

    }
    actorModel = new QSqlTableModel(this, db);
    actorModel->setTable("c_actor");
    actorModel->setEditStrategy(QSqlTableModel::OnManualSubmit);
    actorModel->select();
}

CActor *ActorModel::getActor(const QString &id)
{
    return actorMap.value(id, nullptr);
}

QJsonArray ActorModel::listGroupJson()
{
    QJsonArray array;
    for(int i = 0; i < groupModel->rowCount(); i++) {
        QSqlRecord r = groupModel->record(i);
        array.append(QJsonObject {
            {"id", r.value("id").toString()},
            {"name", r.value("name").toString()}
        });
    }
    return array;
}

QJsonObject ActorModel::addGroupJson(QJsonValue json)
{
    QSqlRecord groupRecord;

    QSqlField f("id", QVariant::Int);
    f.setAutoValue(true);
    f.setGenerated(true);
    groupRecord.append(f);

    QSqlField nameField("name", QVariant::Int);
    nameField.setValue(json.toObject().value("name").toString("unknown"));
    groupRecord.append(nameField);

    groupModel->insertRecord(-1, groupRecord);
    groupModel->submitAll();

    auto r = groupModel->record(groupModel->rowCount() - 1);
    return QJsonObject{
        {"id", r.value("id").toString()},
        {"name", r.value("name").toString()}
    };
}

void ActorModel::removeGroup(int index)
{
    groupModel->removeRow(index);
    groupModel->submitAll();
}

void ActorModel::addActor(QJsonObject json)
{
    auto actor = CActorFactory::create(json, this);
    if (actor) {
        QSqlRecord r;
        auto idf = QSqlField("id", QVariant::Int);
        idf.setAutoValue(true);
        r.append(idf);
        foreach (auto k, json.keys()) {
            auto v = json.value(k).toVariant();
            auto f = QSqlField(k, v.type());
            f.setValue(v);
            r.append(f);
        }
        bool s = actorModel->insertRecord(-1, r);
        actorModel->submitAll();
    }
}

QJsonArray ActorModel::getGroupActors(QString group)
{
    actorMap.clear();
    QJsonArray array;
    actorModel->setFilter(QString("groupId=%1").arg(group.toInt(0)));
    actorModel->select();
    for(int i = 0; i < actorModel->rowCount(); i++) {
        auto r = actorModel->record(i);
        QJsonObject a;
        for(int j = 0; j < r.count(); j++) {
            auto f = r.field(j);
            a.insert(f.name(), f.value().toString());
        }
        array.append(a);

        auto actor = CActorFactory::create(r, this);
        if(actor != nullptr) {
            actorMap.insert(actor->id(), actor);
        }
    }
    return array;
}

void ActorModel::removeActor(QString id)
{
    auto actor = actorMap.take(id);
    if (actor) {
        actor->deleteLater();
    }

    for(int i = 0; i< actorModel->rowCount(); i++) {
        if(actorModel->record(i).value("id").toString() == id) {
            actorModel->removeRow(i);
            break;
        }
    }
    actorModel->submitAll();
}

void ActorModel::removeActors(QString groupId)
{
    db.transaction();
    actorModel->setFilter(QString("groupId=%1").arg(groupId));
    actorModel->select();
    actorModel->removeRows(0, actorModel->rowCount());
    actorModel->submitAll();
    db.commit();
}

CmdActor::CmdActor(QObject *parent):CActor(parent)
{

}

void CmdActor::start(QStringList args)
{
    this->process = new QProcess(this);
    this->process->start(data(), args);

    connect(this->process, &QProcess::readyRead, this, [this]() {
        QString msg(this->process->readAll());
        emit received(msg);
    });

    connect(this->process, &QProcess::stateChanged, this, [this](QProcess::ProcessState newState) {
        if (newState == QProcess::Running) {
            setState("Running");
        } else if (newState == QProcess::Starting) {
            setState("Starting");
        } else if (newState == QProcess::NotRunning) {
            setState("NotRunning");
        }
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
