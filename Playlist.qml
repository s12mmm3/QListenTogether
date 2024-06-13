import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    property alias model: listView.model
    id: root
    signal clicked(id: string)
    header: Column {
        width: parent.width

        Button {
            text: "创建房间"
            visible: !roomInfo.roomId
            onClicked: {
                createRoom()
            }
        }

        Row {
            visible: roomInfo.roomId
            Text {
                text: "分享链接为: "
            }

            TextInput {
                text: `https://st.music.163.com/listen-together/share/?songId=1372188635&roomId=${roomInfo.roomId}&inviterId=${roomInfo.inviterId}`
            }
        }

        Button {
            text: "关闭房间"
            visible: roomInfo.roomId
            onClicked: {
                closeRoom()
            }
        }

        Button {
            text: "同步进度"
            onClicked: {
                seekTrack()
            }
        }

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 2
            Text {
                text: "歌单ID:"
            }
            Rectangle {
                Layout.preferredHeight: parent.height
                Layout.fillWidth: true
                TextInput {
                    anchors.fill: parent
                    text: "8360528574"
                    onTextChanged: {
                        playlistInfo.playlistId = text
                    }
                    Component.onCompleted: {
                        playlistInfo.playlistId = text
                    }
                }
            }
        }

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 2
            Button {
                text: "加载歌单到播放列表"
                onClicked: {
                    loadPlaylist()
                }
            }
            Text {
                Layout.fillWidth: true
                text: playlistInfo.playlistName
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        spacing: 5

        delegate: ItemDelegate {
            width: root.width
            property var track: modelData
            onClicked: function() {
                root.clicked(track.id)
            }

            contentItem: RowLayout {
                spacing: 5
                width: parent.width
                Image {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: Layout.preferredWidth
                    source: track.al.picUrl
                }
                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    Text {
                        text: track.name
                        width: parent.width
                        elide: Text.ElideRight
                    }
                    Text {
                        text: {
                            return modelData["ar"].map(item => item.name).join("/")
                        }
                        width: parent.width
                        elide: Text.ElideRight
                        color: "#708090"
                    }
                    Text {
                        text: modelData["al"]["name"]
                        color: "#708090"
                        width: parent.width
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

}
