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
        //var domain = JS.getInstance()
        /*if (domain !== "") {
	   console.log(domain)
	   url = domain+"/api/v1/search?q="+query+"&region=CZ&type=videos"
	   JS.httpRequest("GET", url, processData)
	}*/
	//url = domain+"/api/v1/search?q="+query+"&region=CZ&type=videos"
	var domain = JS.getInvInstance()
        url = domain+"/api/v1/search?q="+query+"&region=CZ&type=videos"
        console.log(url)
	JS.httpRequest("GET", url, processData)
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        var r="";
        for(var i = 1; i < obj.length; i++) {
            r = { "videoid": obj[i].videoId, "title": obj[i].title, "authorName": obj[i].author, "id": obj[i].authorId }
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
                contentHeight: Theme.itemSizeExtraLarge

                Image {
                    id: img
                    source: "https://inv.nadeko.net/vi/"+videoid+"/hqdefault.jpg"
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
                    text: title + "\n" + authorName
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
                        text: qsTr("Add to favorite")
                        onClicked: {
                                //id_txt = list.model.get(index).rowid
                                JS.addFavItem(list.model.get(index).videoid, list.model.get(index).title, 
list.model.get(index).service)
                }
            }

                    MenuItem {
                        text: qsTr("Otevřít externě na YT")
                        onClicked: {
                            link = "https://youtube.com/watch?v="+list.model.get(index).videoid
                            Qt.openUrlExternally(link);
                        }
                    }
                    MenuItem {
                        text: qsTr("Open audio only")
                        onClicked: {
                    pageStack.push(Qt.resolvedUrl("AudioPlayer.qml"), {audioId: list.model.get(index).videoid, name: list.model.get(index).title});
                        }
                    }
		    MenuItem {
                        text: qsTr("Otevřít kanal")
                        onClicked: {
		pageStack.push(Qt.resolvedUrl("ChannelLatest.qml"), {authorId: list.model.get(index).id, authorName: list.model.get(index).authorName});
                        }
                    }
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Player.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
