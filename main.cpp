#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include "cactor.h"
#include "workspace.h"
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("Skyline Application");
    QCoreApplication::setOrganizationDomain("skyline.com");
    QCoreApplication::setApplicationName("CanaryWorkspace");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<ActorItem>("CActorItem", 1, 0, "CActorItem");
    qmlRegisterType<Pipe>("CPipe", 1, 0, "CPipe");
    qmlRegisterType<CActor>("CActor", 1, 0, "CActor");
//    qmlRegisterType<Workspace>("Workspace", 1, 0, "Workspace");
    qmlRegisterUncreatableType<Workspace>("CWorkspace", 1,0,"CWorkspace",QLatin1String("CWorkspace are read-only"));
    qmlRegisterUncreatableType<WorkspaceModel>("WorkspaceModel", 1,0,"WorkspaceModel",QLatin1String("WorkspaceModel are read-only"));
    qmlRegisterUncreatableType<CActorGroup>("CActorGroup", 1,0,"CActorGroup",QLatin1String("CActorGroup are read-only"));

    auto am = new ActorModel();
    engine.rootContext()->setContextProperty("actorModel", am);
    engine.rootContext()->setContextProperty("workspaceModel", new WorkspaceModel(am));

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
    &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
