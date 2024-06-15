import QtQuick
import QtQuick.Controls

Popup {
    property var url: ""
    property var key: ""
    id: root
    width: 320
    height: 320
    QRCode {
        anchors.fill: parent
        value: root.url
        visible: value != ""
    }
    function init() {
        url = ""
        key = ""
    }

    onOpened: {
        init()
        login()
        timer.start()
    }
    onClosed: {
        timer.stop()
    }

    Timer {
        id: timer
        interval: 3000
        repeat: true
        onTriggered: {
            const statusRes = checkStatus(key)
            if (statusRes.code === 800) {
                window.alert('二维码已过期,请重新获取')
                stop()
            }
            if (statusRes.code === 803) {
                // 这一步会返回cookie
                window.alert('授权登录成功')
                stop()
            }
        }
    }

    function login() {
        const res = invoke("login_qr_key", {})
        const key = res.data.data.unikey
        const res2 = invoke("login_qr_create",
                            {
                                "key": key
                            })
        root.url = res2.data.data.qrurl
        root.key = key

    }
    function checkStatus(key) {
        const res = invoke("login_qr_check",
                           {
                               "key": key
                           })
        return res.data
      }
}
