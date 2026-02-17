import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import io.thp.pyotherside 1.5
import "../main.js" as JS

Page {
    id: page
    property string query
    property string link

    //property string userRegion: Qt.locale().name.split("_")[1] || "US" // eg. "CZ" or fallback "US"

    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../python"))
            importModule("backend", function() {
                console.log("Python backend loaded")
                indicatior.running = true
                search(query)   // <-- až po loadu backendu
                print("search query:", query)
            })
        }
    }

    function search(query) {
        indicatior.running = true

        py.call("backend.search_videos", [query, 20], function(res) {
            indicatior.running = false

            if (!res.ok) {
                console.log("yt-dlp search error:", res.error)
                return
            }

            myJSModel.clear()

            for (var i = 0; i < res.videos.length; i++) {
                var v = res.videos[i]
                myJSModel.append({
                                     "videoid": v.videoId,
                                     "title": v.title,
                                     "authorName": v.author,
                                     "id": v.authorId,
                                     "videolength": v.lengthSeconds,
                                     //"thumbnail": v.thumbnail
                                 })
            }

            console.log("searching for:", query)

        })
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
                    pageStack.push(Qt.resolvedUrl("YT.qml"), {videoId: list.model.get(index).videoid, name: list.model.get(index).title});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
