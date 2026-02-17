import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0

TabItem {
    id: url

    property alias flickable: flickable
    property string mode: "video"
    property string inputUrl

    anchors.fill: parent

    BusyIndicator {
        id: indicatior
        running: false
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    SilicaFlickable {
        id: flickable

        anchors.fill: parent

        VerticalScrollDecorator {
            flickable: flickable
        }

        contentHeight: column.height
        anchors.topMargin: 300//sr.height / 8

        SearchField {
            id: urlField
            width: page.width

            anchors {
                left: parent.left
                right: parent.right
            }
            placeholderText: qsTr("Paste link")
            text: inputUrl
            //inputMethodHints: Qt.ImhNoPredictiveText
            EnterKey.onClicked: {
                onClicked: pageStack.push(Qt.resolvedUrl("YT-DLP.qml"), {inputUrl: urlField.text});

            }
        }
    }

}
