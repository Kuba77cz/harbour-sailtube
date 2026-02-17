import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

TabItem {
    id: hs

    property alias flickable: flickable
    property string id_txt
    property string text
    property int type
    property string imageurl

    anchors.fill: parent

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
                contentHeight: Theme.itemSizeExtraLarge

                Image {
                    id: img
                    source: {
                        if (list.model.get(index).service === 1) {
                            var url = "https://peertube.arch-linux.cz/api/v1/videos/"+videoid
                            JS.httpRequest("GET", url, function(response) { JS.processData(response, img);});
                        } else {
                            JS.getInvInstance()+"/vi/"+videoid+"/mqdefault.jpg"
                        }
                    }
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
                        text: qsTr("Add to favorite")
                        onClicked: {
                            if (list.model.get(index).service === 1) {
                                JS.addFavItem(list.model.get(index).videoid, list.model.get(index).title,
                                              list.model.get(index).service)
                            } else {
                                JS.addFavItem(list.model.get(index).videoid, list.model.get(index).title, list.model.get(index).service)
                            }
                        }
                    }
                    MenuItem {
                        text: qsTr("Copy link to clipboard")
                        onClicked: {
                            if (list.model.get(index).service === 1) {
                                Clipboard.text = "https://peertube.arch-linux.cz/w/"+list.model.get(index).videoid
                            } else {
                                Clipboard.text = "https://youtube.com/watch?v="+list.model.get(index).videoid
                            }

                        }
                    }
                    MenuItem {
                        text: qsTr("Open audio only")
                        onClicked: {
                            if (list.model.get(index).service === 1) {
                                pageStack.push(Qt.resolvedUrl("PT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title, mode: "audio"});
                            } else {
                                pageStack.push(Qt.resolvedUrl("YT.qml"), {videoId: list.model.get(index).videoid, name:
                                                   list.model.get(index).title, mode: "audio"});
                            }
                        }
                    }
                    MenuItem {
                        text: qsTr("Open channel")
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("ChannelLatest.qml"), {authorId: list.model.get(index).id, authorName: list.model.get(index).authorName});
                        }
                    }
                    MenuItem {
                        text: qsTr("Open link externally")
                        onClicked: {
                            var link;
                            if (list.model.get(index).service === 1) {
                                link = "https://peertube.arch-linux.cz/w/"+list.model.get(index).videoid
                                Qt.openUrlExternally(link);
                            } else {
                                link = "https://youtube.com/watch?v="+list.model.get(index).videoid
                                Qt.openUrlExternally(link);
                            }

                        }
                    }
                    MenuItem {
                        text: qsTr("Remove from history")
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
                        pageStack.push(Qt.resolvedUrl("PT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title, service: list.model.get(index).service});
                    } else {
                        pageStack.push(Qt.resolvedUrl("YT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title});
                    }

                    // pageStack.push(Qt.resolvedUrl("YT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title});
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
