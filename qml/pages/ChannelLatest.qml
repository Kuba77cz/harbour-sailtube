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
    property string domain: JS.getInvInstance()

    Component.onCompleted: {
        indicatior.running = true
        var url;
	//var domain = JS.getInvInstance()
        url = domain + "/api/v1/channels/"+authorId+"/latest" //latest
        console.log(url)
        JS.httpRequest("GET", url, processData)
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        var r="";
        for(var i = 0; i < obj.videos.length; i++) {
            r = { "id": obj.videos[i].videoId, "title": obj.videos[i].title, "datepub": obj.videos[i].publishedText }
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
                contentHeight: Theme.itemSizeMedium

                Image {
                    id: img
                    source: domain+"/vi/"+id+"/hqdefault.jpg"
                    width: Theme.iconSizeLarge
                    height: Theme.iconSizeLarge
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
                        text: qsTr("Open audio only")                                                                                                                  
                        onClicked: {                                                                                                                                   
                   		 pageStack.push(Qt.resolvedUrl("AudioPlayer.qml"), {audioId: list.model.get(index).videoid, name: list.model.get(index).title});                    
                        }                                                                                                                                              
                    }        
                    MenuItem {
                        text: qsTr("Otevřít externě")
                        onClicked: {
                            link = "https://invidious.fdn.fr/watch?v="+list.model.get(index).id
                            Qt.openUrlExternally(link);
                        }
                    }
                    MenuItem {
                        text: qsTr("Otevřít externě pouze zvuk")
                        onClicked: {
                            link = "https://invidious.fdn.fr/watch?v="+list.model.get(index).id+"&listen=1"
                            Qt.openUrlExternally(link);
                        }
                    }
                    MenuItem {
                        text: qsTr("Otevřít na Youtube")
                        onClicked: {
                                link = "https://youtube.com/watch?v="+list.model.get(index).id
                                Qt.openUrlExternally(link);
                        }
                     }

                }
                onClicked: {
			pageStack.push(Qt.resolvedUrl("Player.qml"), {videoId: list.model.get(index).id, name: list.model.get(index).title });
                    //pageStack.push(Qt.resolvedUrl("WebView.qml"), {videoId: list.model.get(index).id, artistName: list.model.get(index).title });
                    //pageStack.push(Qt.resolvedUrl("ChannelLatest.qml"), {authorId: list.model.get(index).id, authorName: list.model.get(index).authorId});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
