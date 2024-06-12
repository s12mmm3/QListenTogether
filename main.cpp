#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "QCloudMusicApi/QCloudMusicApi/apihelper.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    ApiHelper apihelper;
    engine.rootContext()->setContextProperty("$apihelper", &apihelper);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("QListenTogether", "Main");

    return app.exec();
}
