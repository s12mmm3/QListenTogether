cmake_minimum_required(VERSION 3.16)

project(QListenTogether VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(MUSICAPI_TEST "Build Test" OFF)
option(MUSICAPI_SERVER "Build ApiServer" OFF)
option(MUSICAPI_SETOUTPUTPATH "Set default output path" OFF)

if(NOT ANDROID AND NOT IOS)
    # 设置安装前缀为二进制目录
    set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR})

    # set default output path
    set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
    set(CMAKE_HEADER_OUTPUT_DIRECTORY include)

    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE} ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
endif()

add_subdirectory(QCloudMusicApi)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2)

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

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt6::Quick Qt6::QuickControls2 QCloudMusicApi
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
