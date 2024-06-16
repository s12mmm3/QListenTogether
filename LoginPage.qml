import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    property var url: ""
    property var key: ""
    id: root
    Column {
        width: parent.width
        spacing: 5
        QRCode {
            width: parent.width
            height: width
            value: root.url
            visible: value != ""
        }
        TextField {
            id: phone
            placeholderText: "账号"
            width: parent.width
        }
        TextField {
            id: password
            placeholderText: "密码"
            width: parent.width
        }
        Button {
            text: "登录"
            onClicked: {
                const res = invoke("login_cellphone",
                                   {
                                       "password": password.text,
                                       "phone": phone.text
                                   })
                if (res.data.cookie) {
                    window.alert('授权登录成功')
                    timer.stop()
                }
                else {
                    window.alert('登录失败，请尝试重新登录或扫码')
                }
            }
        }
    }

    function init() {
        root.url = ""
        root.key = ""
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
