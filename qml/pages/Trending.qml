import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

Page {
    id: page
    property string authorId
    property string link
    property string authorName
    property string type

    Component.onCompleted: {
        indicatior.running = true
        var url;
	var domain = JS.getInvInstance()
        url = domain+"/api/v1/trending?region=CZ&type="+type
        console.log(url)
        JS.httpRequest("GET", url, processData)
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        var r="";
        for(var i = 0; i < obj.length; i++) {
            r = { "id": obj[i].videoId, "title": obj[i].title, "authorName": obj[i].author }
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
                title: (type==="music") ? "Trending music" : (type==="movies") ? "Trending movies" : (type==="news") ? "Trending news" : (type==="gaming") ? "Trending" : "Trending"
            }
            delegate: ListItem {
                id: column
                width: parent.width
                contentHeight: Theme.itemSizeExtraLarge

                Image {
                    id: img
                    source: 
"https://invidious.fdn.fr/vi/"+id+"/hqdefault.jpg"
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
                        text: qsTr("Otevřít externě")
                        onClicked: {
		pageStack.push(Qt.resolvedUrl("WebView.qml"), 
{videoId: list.model.get(index).id})
                            
//link = "https://youtube.com/watch?v="+list.model.get(index).id
                            //Qt.openUrlExternally(link);
                        }
                    }
                    MenuItem {
                        text: qsTr("Otevřít externě pouze zvuk")
                        onClicked: {
                            link = "https://iteroni.com/watch?v="+list.model.get(index).id+"&listen=1"
                            Qt.openUrlExternally(link);
                        }
                    }
                }
                onClicked: {
                    //JS.deleteItemVI(list.model.get(index).id)
                    pageStack.push(Qt.resolvedUrl("Player.qml"), {videoId: list.model.get(index).id, name: list.model.get(index).title });
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
