import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtMultimedia

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("一起听 - 主机模式")
    function invoke(member, arg) {
        return {
            "data": $apihelper.invoke(member, arg).body
        }
    }
    MediaPlayer {
        id: player
        audioOutput: AudioOutput {}
    }

    Component.onCompleted: {
        loadPlaylist()
    }
    property var message: '请点击获取登录状态'
    property var account: {
        "login": false,
        "userId": 0,
        "nickname": '未登录',
    }
    property var roomInfo: {
        "roomId": null,
        "inviterId": 0,
        "roomUsers": [],
    }
    property var playlistInfo: {
        "playlistId": "8360528574",
        "playlistName": '未获取',
        "playlistTrackIds": [],
        "playlistTracks": []
    }
    property var playingInfo: {
        "trackId": 0,
        "status": 'PLAY',
        "progress": 1,
    }
    property int clientSeq: 1
    function login() {
        const res = invoke("login_status",
                           {

                           })
        console.info(JSON.stringify(res, null, 2))
        if (res.data.data.code !== 200) {
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

    function loadPlaylist() {
        const res = invoke("playlist_detail",
                           {
                               "id": this.playlistInfo.playlistId,
                           })
        this.playlistInfo.playlistName = res.data.playlist.name
        this.playlistInfo.playlistTrackIds = res.data.playlist.trackIds
        .map((track) => track.id)
        .join(',')
        console.info(this.playlistInfo.playlistName)
        console.info(this.playlistInfo.playlistTrackIds)

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
        player.source =
                res.data.data[0].url
        player.play()
    }

    function playCommand(action) {
        const res = invoke("listentogether_play_command",
                           {
                               "roomId": this.roomInfo.roomId,
                               "progress": Math.floor(
                                               player.duration,
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
    ListView {
        id: listView
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        clip: true
        spacing: 5
        model: playlistInfo.playlistTracks

        delegate: ItemDelegate {
            width: listView.width
            property var track: modelData
            onClicked: function() {
                gotoTrack(track.id)
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
