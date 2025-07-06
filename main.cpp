#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QLoggingCategory>

#include "QCloudMusicApi/apihelper.h"

int main(int argc, char *argv[])
{
    qSetMessagePattern("%{time yyyy-MM-dd hh:mm:ss.zzz} : %{threadid} : %{category} : %{type} : %{line} : %{function} : %{message}");
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    ApiHelper apihelper;
    apihelper.setFilterRules("QCloudMusicApi.debug=false");
    engine.rootContext()->setContextProperty("$apihelper", &apihelper);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("main", "Main");

    return app.exec();
}
