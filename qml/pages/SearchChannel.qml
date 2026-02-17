import QtQuick 2.0
import Sailfish.Silica 1.0
import "../main.js" as JS

Page {
    id: page
    property string query
    property string link

    property string userRegion: Qt.locale().name.split("_")[1] || "US" // eg. "CZ" or fallback "US"

    Component.onCompleted: {
        indicatior.running = true
        var url;
        var domain = JS.getInvInstance()
        var region = userRegion || "US";
        url = domain+"/api/v1/search?q="+query+"&region="+region+"&type=channel"
        console.log(url)
        JS.httpRequest("GET", url, processData)
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        var r="";
        for(var i = 0; i < obj.length; i++) {
            r = { "id": obj[i].authorId, "author": obj[i].author, "thumbnail": "https:"+obj[i].authorThumbnails[3].url }
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

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ChannelLatest.qml"), {authorId: list.model.get(index).id, authorName: list.model.get(index).author});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
