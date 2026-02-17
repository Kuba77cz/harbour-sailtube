import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
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
        url = domain+"/api/v1/search?q="+query+"&region="+region+"&type=videos"
        console.log(url + " ; " + region)
        JS.httpRequest("GET", url, processData)
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        var r="";
        for(var i = 1; i < obj.length; i++) {
            var videoLength = obj[i].lengthSeconds;
            if (videoLength && videoLength > 0) {
                r = { "videoid": obj[i].videoId, "title": obj[i].title, "authorName": obj[i].author, "id": obj[i].authorId,
                    "videolength": obj[i].lengthSeconds };
                myJSModel.append(r)
            }
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
                    source: JS.getInvInstance()+"/vi/"+videoid+"/mqdefault.jpg"
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

                Rectangle {
                    id: lengthBadge

                    anchors {
                        right: img.right
                        bottom: img.bottom
                        rightMargin: Theme.paddingSmall
                        bottomMargin: Theme.paddingSmall * 7.2
                    }

                    color: Theme.highlightDimmerColor
                    radius: Theme.paddingSmall / 2
                    opacity: 0.85

                    width: vlength.width + Theme.paddingSmall * 2
                    height: vlength.height + Theme.paddingSmall

                    Label {
                        id: vlength
                        anchors.centerIn: parent
                        text: JS.formatSeconds(videolength)
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.primaryColor
                    }
                }
                Label {
                    text: title + "\n" + authorName
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
                            JS.addFavItem(list.model.get(index).videoid, list.model.get(index).title, list.model.get(index).service)
                        }
                    }
                    MenuItem {
                        text: qsTr("Copy link to clipboard")
                        onClicked: {
                            Clipboard.text = "https://youtube.com/watch?v="+list.model.get(index).videoid
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
                        text: qsTr("Open audio only")
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("YT.qml"), {videoId: list.model.get(index).videoid, name:
                                               list.model.get(index).title, mode: "audio"});
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
                            link = "https://youtube.com/watch?v="+list.model.get(index).videoid
                            Qt.openUrlExternally(link);
                        }
                    }
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("YT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title, mode: "video"});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
