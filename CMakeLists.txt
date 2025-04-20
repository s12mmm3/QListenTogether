cmake_minimum_required(VERSION 3.16)

project(QListenTogether VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zi /EHa")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /DEBUG")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /DEBUG")
    set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
endif()

set(BUILD_SHARED_LIBS OFF)
set(MUSICAPI_TEST OFF)

add_subdirectory(3rdparty/QCloudMusicApi)
include_directories(3rdparty/QCloudMusicApi)

find_package(Qt6 6.5 REQUIRED COMPONENTS Multimedia Quick QuickControls2 Network)

qt_standard_project_setup(REQUIRES 6.5)

FILE(GLOB HEADERS ./*.h)
FILE(GLOB SOURCES ./*.cpp)
qt_add_executable(${PROJECT_NAME}
    ${HEADERS}
    ${SOURCES}
)

set(resource_files
    "Mute_Icon.svg"
    "Speaker_Icon.svg"
)

qt_add_resources(${PROJECT_NAME} "${PROJECT_NAME}"
    PREFIX
        "/"
    FILES
        ${resource_files}
)

set_source_files_properties(qqr.js/QRCode.qml PROPERTIES
    QT_RESOURCE_ALIAS QRCode.qml
)

set_source_files_properties(qqr.js/qqr.js PROPERTIES
    QT_RESOURCE_ALIAS qqr.js
)

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    QML_FILES
        Main.qml
        AudioControl.qml
        PlaybackControl.qml
        PlaybackRateControl.qml
        PlaybackSeekControl.qml
        Playlist.qml
        qqr.js/QRCode.qml
        qqr.js/qqr.js
        LoginPage.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${PROJECT_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.${PROJECT_NAME}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

if (ANDROID)
    include(FetchContent)
    FetchContent_Declare(
        android_openssl
        DOWNLOAD_EXTRACT_TIMESTAMP true
        URL https://github.com/KDAB/android_openssl/archive/refs/heads/master.zip
        )
    FetchContent_MakeAvailable(android_openssl)
    include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)

    add_android_openssl_libraries(${PROJECT_NAME})
else()

endif()
target_compile_definitions(${PROJECT_NAME} PRIVATE
    PROJECT_NAME="${PROJECT_NAME}"
    QT_MESSAGELOGCONTEXT
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Multimedia
    QCloudMusicApi
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${PROJECT_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appCMakeTest
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
