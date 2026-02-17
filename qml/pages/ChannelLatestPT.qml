import QtQuick 2.0
import Sailfish.Silica 1.0
import "../main.js" as JS

Page {
    id: page
    property string authorId
    property string link
    property string authorName
    property string videoUrl
    property string origUrl

    Component.onCompleted: {
        indicatior.running = true
        var url = "https://peertube.arch-linux.cz/api/v1/accounts/archlinuxcz/videos"
        console.log(url)
        JS.httpRequest("GET", url, processData)
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        var r="";
        for(var i = 0; i < obj.data.length; i++) {
            r = { "id": obj.data[i].uuid, "title": obj.data[i].name, "thumbnail": obj.data[i].thumbnailPath }
            myJSModel.append(r)
        }

        indicatior.running = false
        return r;
    }
    BusyIndicator {
        id: indicatior
        running: false
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        SilicaListView {
            id:list
            anchors.fill: parent

            model: ListModel {
                id: myJSModel
            }
            header: PageHeader {
                id: header
                title: authorName + "- latest"
            }
            delegate: ListItem {
                id: column
                width: parent.width
                contentHeight: Theme.itemSizeExtraLarge

                Image {
                    id: img
                    source: "https://peertube.arch-linux.cz" + thumbnail
                    width: Theme.iconSizeExtraLarge * 1.5
                    height: Theme.iconSizeExtraLarge * 1.5
                    fillMode: Image.PreserveAspectFit
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                }

                Label {
                    text: title
                    width: column.width - 92
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 3
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    anchors {
                        left: img.right
                        leftMargin: Theme.horizontalPageMargin
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                }

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Audio only")
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("PT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title, mode: "audio"});
                        }
                    }
                    MenuItem {
                        text: qsTr("Copy link to clipboard")
                        onClicked: {
                            Clipboard.text = "https://peertube.arch-linux.cz/w/"+list.model.get(index).videoid
                        }
                    }
                    MenuItem {
                        text: qsTr("Open link externally")
                        onClicked: {
                            var link = "https://peertube.arch-linux.cz/w/"+list.model.get(index).videoid
                            Qt.openUrlExternally(link);
                        }
                    }
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("PT.qml"), {videoId: list.model.get(index).id, name: list.model.get(index).title});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
