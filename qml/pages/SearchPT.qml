import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

Page {
    id: page
    property string query
    property string link


    Component.onCompleted: {
        indicatior.running = true
        var url;
        url = "https://peertube.arch-linux.cz/api/v1/search/videos?search="+query
        console.log(url)
        JS.httpRequest("GET", url, processData)
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
//        console.log(data)
        var r="";
        for(var i = 0; i < obj.total; i++) {
            r = { "videoid": obj.data[i].uuid, "title": obj.data[i].name, "thumbnail": 
obj.data[i].thumbnailPath }
            myJSModel.append(r)
        }
        indicatior.running = false
        return r;
    }

    function processDataV(data) {
        var json = data;
        var obj = JSON.parse(json);
//        console.log(data)
        var link="";
        var pom="";
        pom = obj.streamingPlaylists[0].playlistUrl
        link = pom.toString()
        console.log(link) 
        return link
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
                contentHeight: Theme.itemSizeExtraLarge

                Image {
                    id: img
                    source: "https://peertube.arch-linux.cz" + thumbnail
                    width: Theme.iconSizeExtraLarge
                    height: Theme.iconSizeExtraLarge
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
				pageStack.push(Qt.resolvedUrl("AudioPlayerPT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title});
                        }
                    }
		    MenuItem {
                        text: qsTr("Otevřít kanal")
                        onClicked: {
		pageStack.push(Qt.resolvedUrl("ChannelLatestPT.qml"), {authorId: list.model.get(index).id, authorName: list.model.get(index).authorName});
                        }
                    }
                }
                onClicked: {
                    //var urlV = 
"https://peertube.arch-linux.cz/api/v1/videos/"+list.model.get(index).videoid

                    //var linkid = JS.httpRequest("GET", urlV, processDataV)
                    //var linkid = pom.toString()
                    pageStack.push(Qt.resolvedUrl("PlayerPT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
