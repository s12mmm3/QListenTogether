import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtMultimedia
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("一起听 - 主机模式")
    MessageDialog {
        id: messageDialog
    }

    function alert(text) {
        messageDialog.text = text
        messageDialog.open()
    }
    function invoke(member, arg) {
        return {
            "data": $apihelper.invoke(member, arg).body
        }
    }
    MediaPlayer {
        id: mediaPlayer
        audioOutput: AudioOutput {
            id: audio
            muted: playbackControl.muted
            volume: playbackControl.volume
        }
        onErrorOccurred: { mediaErrorText.text = mediaPlayer.errorString; mediaError.open() }
    }

    Connections {
        target: mediaPlayer
        function onPlaybackStateChanged() {
            if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                playTrack()
            }
            else if (mediaPlayer.playbackState == MediaPlayer.PausedState) {
                pauseTrack()
            }
        }
    }

    Component.onCompleted: {
        $apihelper.setFilterRules("*.debug=false")
    }
    property string message: '请点击获取登录状态'
    property alias account: account
    QtObject {
        id: account
        property var login: false
        property var userId: 0
        property var nickname: '未登录'
    }

    property alias roomInfo: roomInfo
    QtObject {
        id: roomInfo
        property var roomId: null
        property var inviterId: 0
        property var roomUsers: []
    }

    property alias playlistInfo: playlistInfo
    QtObject {
        id: playlistInfo
        property var playlistId: ""
        property var playlistName: '未获取'
        property var playlistTrackIds: []
        property var playlistTracks: []
    }

    property alias playingInfo: playingInfo
    QtObject {
        id: playingInfo
        property var trackId: 0
        property var status: 'PLAY'
        property var progress: 1
    }

    property int clientSeq: 1

    function login() {
        const res = invoke("login_status",
                           {

                           })
        console.info(JSON.stringify(res, null, 2))
        if (res.data.data.code != 200) {
            alert('请先使用登录 API 登录到网易云音乐')
        } else {
            this.account.userId = res.data.data.profile.userId
            this.account.nickname = res.data.data.profile.nickname
            this.account.login = true
            this.message = '成功登录, 请创建房间'
        }
    }
    function joinRoom() {
        const res = invoke("listentogether_accept",
                           {
                               "roomId": this.roomInfo.roomId,
                               "inviterId": this.roomInfo.inviterId,
                           })
        console.log(res)
        if (res.data.code != 200) {
            this.message = '加入房间出现问题: ' + res.data.message
        } else {
            this.message = '加入房间成功: ' + this.roomInfo.roomId
            const res2 = invoke("listentogether_room_check",
                                {
                                    "roomId": this.roomInfo.roomId,
                                })
            console.log(res2)
            const res3 = invoke("listentogether_sync_playlist_get",
                                {
                                    "roomId": this.roomInfo.roomId,
                                })

            this.playlistInfo.playlistName = "其他人的歌单"
            this.playlistInfo.playlistTrackIds = res3.data.data.playlist.displayList.result
            .join(',')
            const resa = invoke("song_detail",
                                {
                                    "ids": this.playlistInfo.playlistTrackIds
                                })
            console.log(resa)
            this.playlistInfo.playlistTracks = resa.data.songs
        }
    }

    function createRoom() {
        const res = invoke("listentogether_room_create", {})
        console.log(res)
        if (res.data.code != 200) {
            this.message = '创建房间出现问题: ' + res.data.message
        } else {
            this.message = '创建房间成功: ' + res.data.data.roomInfo.roomId
            this.roomInfo.inviterId = this.account.userId
            this.roomInfo.roomId = res.data.data.roomInfo.roomId
            const res2 = invoke("listentogether_room_check",
                                {
                                    "roomId": this.roomInfo.roomId,
                                    // "cookie": localStorage.getItem('cookie'),
                                })
            console.log(res2)
        }
    }

    function refreshRoom() {
        const res = invoke("listentogether_status", {})
        console.log(res)
        if (res.data.code != 200 || !res.data.data.inRoom) {
            this.message = '房间状态获取失败, 可能退出了房间'
        } else {
            this.roomInfo.roomUsers = res.data.data.roomInfo.roomUsers
        }
    }

    function closeRoom() {
        const res = invoke("listentogether_end",
                           {
                               "roomId": this.roomInfo.roomId
                           })
        console.log(res)
        if (res.data.code != 200 || !res.data.data.success) {
            this.message = '房间关闭失败'
        } else {
            this.message = '房间关闭成功'
            this.roomInfo.roomId = null
        }
    }

    function loadPlaylist() {
        const res = invoke("playlist_detail",
                           {
                               "id": this.playlistInfo.playlistId,
                           })
        this.playlistInfo.playlistName = res.data.playlist.name
        this.playlistInfo.playlistTrackIds = res.data.playlist.trackIds
        .map((track) => track.id)
        .join(',')

        const resa = invoke("song_detail",
                            {
                                "ids": this.playlistInfo.playlistTrackIds
                            })
        this.playlistInfo.playlistTracks = resa.data.songs
        if (this.roomInfo.roomId) {
            const resb = invoke("listentogether_sync_list_command",
                                {
                                    "roomId": this.roomInfo.roomId,
                                    "commandType": 'REPLACE',
                                    "userId": this.account.userId,
                                    "version": this.clientSeq++,
                                    "playMode": 'ORDER_LOOP',
                                    "displayList": this.playlistInfo.playlistTrackIds,
                                    "randomList": this.playlistInfo.playlistTrackIds,
                                    // "cookie": localStorage.getItem('cookie'),
                                })
            console.log(resb)
        }
        listView.model = playlistInfo.playlistTracks
    }

    function gotoTrack(trackId) {
        this.playingInfo.trackId = trackId
        if (this.roomInfo.roomId) {
            this.playCommand('GOTO')
        }
        const res = invoke("song_url_v1",
                           {
                               "id": trackId,
                               "level": 'hires',
                           })
        mediaPlayer.source =
                res.data.data[0].url
        mediaPlayer.play()
    }

    function playTrack() {
        this.playCommand('PLAY')
    }

    function pauseTrack() {
        this.playCommand('PAUSE')
    }

    function seekTrack() {
        this.playCommand('seek')
    }

    function playCommand(action) {
        const res = invoke("listentogether_play_command",
                           {
                               "roomId": this.roomInfo.roomId,
                               "progress": Math.floor(
                                               mediaPlayer.duration,
                                               ),
                               "commandType": action,
                               "formerSongId": '-1',
                               "targetSongId": this.playingInfo.trackId,
                               "clientSeq": this.clientSeq++,
                               "playStatus": this.playingInfo.status,
                               // cookie: localStorage.getItem('cookie'),
                           })
        console.log(res)
    }
    LoginPage {
        id: loginPage
        width: Math.min(parent.width, parent.height)
        height: width
        visible: false
        anchors.centerIn: parent
    }

    header: Column {
        width: parent.width
        Button {
            text: "如果没登录,请先登录"
            onClicked: {
                loginPage.open()
            }
        }

        Text {
            text: `消息: ${message}`
        }

        Button {
            text: "获取登录状态"
            visible: !account.login
            onClicked: login()
        }

        Text {
            text: `您的当前登录账号为: ${account.nickname}`
        }

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
            text: "刷新房间状态"
            onClicked: {
                refreshRoom()
            }
        }

        Text {
            text: "在线用户: "
        }
        Repeater {
            model: roomInfo.roomUsers
            Row {
                property var user: modelData
                Image {
                    width: 80
                    height: width
                    source: user.avatarUrl
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: user.nickname
                }
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

        TabBar {
            id: bar
            width: parent.width
            Repeater {
                model: [ "主机模式", "从机模式" ]
                TabButton {
                    text: modelData
                }
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

    StackLayout {
        anchors.fill: parent
        currentIndex: bar.currentIndex
        Playlist {
            id: listView
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            model: playlistInfo.playlistTracks
            onClicked: function(id) { gotoTrack(id) }
        }
        Item {
            id: discoverTab
        }
        Item {
            id: activityTab
        }
    }


    footer: PlaybackControl {
        id: playbackControl

        mediaPlayer: mediaPlayer
    }
}
