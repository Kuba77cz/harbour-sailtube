import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

TabItem {
    id: sa

    property alias flickable: flickable
    property string id_txt
    property string text
    property int type
    property string imageurl

    anchors.fill: parent
    
    function send() {
        switch (cbType.currentIndex)
        {
        case 0: type = 0; pageStack.push(Qt.resolvedUrl("Search.qml"), {query: searchfield.text, type2: type }); break;
        case 1: type = 1; pageStack.push(Qt.resolvedUrl("SearchChannel.qml"), {query: searchfield.text, type2: type }); break;
        //case 3: type = 3; break;
        default: type = 0; break;
        }
        console.log(type)
    }
   
    function processData(data, imageElement) {
        var json = data;
        var obj = JSON.parse(json);
        //var ="";
	if (obj.thumbnailPath.length > 0) {
	    imageurl = "https://peertube.arch-linux.cz" + obj.thumbnailPath;
	    imageElement.source = imageurl;
	    return imageurl;
	}
    } 

    function refresh(){
        myJSModel.clear()
        JS.getAllItems()
    }

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


        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        SilicaListView {
            id:list
            width: parent.width
            height: parent.height
            anchors.fill: parent
            VerticalScrollDecorator {}

            model: ListModel {
                id: myJSModel
            }

            delegate: ListItem{
                id: column
                width: parent.width
                contentHeight: Theme.itemSizeMedium
                
                Image {
                    id: img
                    source: {
                        if (list.model.get(index).service === 1) {
			    var url = "https://peertube.arch-linux.cz/api/v1/videos/"+videoid
                            JS.httpRequest("GET", url, function(response) { processData(response, img);});
                        } else {
                            JS.getInvInstance()+"/vi/"+videoid+"/mqdefault.jpg"
                        }
                    }
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
                        text: qsTr("Open audio only")
                        onClicked: {
				if (list.model.get(index).service === 1) {  
                    			pageStack.push(Qt.resolvedUrl("AudioPlayerPT.qml"), {audioId: list.model.get(index).videoid, name: list.model.get(index).title, service: list.model.get(index).service});
                        	} else {
					pageStack.push(Qt.resolvedUrl("AudioPlayer.qml"), {audioId: list.model.get(index).videoid, name: list.model.get(index).title});
				}
			}
                    }
                    MenuItem {
                        text: qsTr("Add to favorite")
                        onClicked: {
                            //id_txt = list.model.get(index).rowid
                            JS.addFavItem(list.model.get(index).videoid, list.model.get(index).title, list.model.get(index).service)
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            id_txt = list.model.get(index).rowid
                            deleteRemorse.execute("Deleting "+list.model.get(index).title)
                            JS.deleteItem(id_txt)
                        }
                    }
                }
                onClicked: {
                    JS.deleteItem(list.model.get(index).rowid)
		    //if (list.model.get(index).source ) {
 	            if (list.model.get(index).service === 1) {
            pageStack.push(Qt.resolvedUrl("PlayerPT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title, service: list.model.get(index).service});
        	    } else {
            pageStack.push(Qt.resolvedUrl("Player.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title});
        }

                   // pageStack.push(Qt.resolvedUrl("Player.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title});
                    myJSModel.clear()
                    JS.getAllItems()
                }
            }

            Component.onCompleted: {
                refresh()
                //appWindow.firstPage = firstPage
            }
            RemorsePopup {
                id: deleteRemorse
                onTriggered: {
                    JS.deleteItem(id_txt)
                    myJSModel.clear()
                    JS.getAllItems()
                }
            }
        }  


        }
    }
