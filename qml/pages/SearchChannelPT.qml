import QtQuick 2.0
import Sailfish.Silica 1.0
import "../main.js" as JS

Page {
    id: page
    property string query
    property string link
    property string type2

    Component.onCompleted: {
        indicatior.running = true
        var url;
        url = "https://peertube.arch-linux.cz/api/v1/search/video-channels?search="+query+"&start=0&count=10"
        console.log(url)
        JS.httpRequest("GET", url, processData)
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        var r="";
        for(var i = 0; i < obj.data.length; i++) {
            r = { "id": obj.data[i].name, "author": obj.data[i].displayName, "thumbnail": "https:"+obj.data[i].ownerAccount.avatars[0].path }
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
                title: qsTr("Results of: ")+query
            }
            delegate: ListItem {
                id: column
                width: parent.width
                contentHeight: Theme.itemSizeMedium

                Image {
                    id: img
                    source: thumbnail
                    width: Theme.iconSizeLarge - 10
                    height: Theme.iconSizeLarge - 10
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                }

                Label {
                    text: author
                    width: column.width - 92
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    anchors {
                        left: img.right
                        leftMargin: Theme.horizontalPageMargin
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                }

//                menu: ContextMenu {
//                    MenuItem {
//                        text: qsTr("Otevřít externě")
//                        onClicked: {
//                            link = "https://iteroni.com/watch?v="+list.model.get(index).id
//                            Qt.openUrlExternally(link);
//                        }
//                    }
//                    MenuItem {
//                        text: qsTr("Otevřít externě pouze zvuk")
//                        onClicked: {
//                            link = "https://iteroni.com/watch?v="+list.model.get(index).id+"&listen=1"
//                            Qt.openUrlExternally(link);
//                        }
//                    }
//                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ChannelLatestPT.qml"), {authorId: list.model.get(index).id, authorName: list.model.get(index).author});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
