import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ListView {
    id: root
    anchors.fill: parent
    anchors.leftMargin: 5
    anchors.rightMargin: 5
    clip: true
    spacing: 5
    signal clicked(id: string)

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
