import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

Page {
    id: page
    property string authorId
    property string link
    property string authorName
    property string videoUrl
    property string origUrl
    property string domain: JS.getInvInstanceImg()

    function showErrorPage(errText) {
        pageStack.push("ErrorPage.qml", {
                           errorText: errText
                       })
    }

    Component.onCompleted: {
        indicatior.running = true
        loadLatest(authorId)
    }

    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../python"))
            importModule("backend", function() {
                console.log("Python backend loaded")
            })
        }
    }

    function loadLatest(authorId) {
        py.call("backend.get_channel_latest", [authorId, 20], function(res) {
            indicatior.running = false

            if (!res.ok) {
                console.log("yt-dlp error:", res.error)
                showErrorPage("yt-dlp error:\n\n"+res.error)
                return
            }

            myJSModel.clear()

            for (var i = 0; i < res.videos.length; i++) {
                var v = res.videos[i]
                myJSModel.append({
                                     "id": v.videoId,
                                     "title": v.title,
                                     "videolength": v.lengthSeconds
                                     //"datepub": v.publishedText
                                 })
            }
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
                title: authorName + " - latest"
            }
            delegate: ListItem {
                id: column
                width: parent.width
                contentHeight: Theme.itemSizeExtraLarge

                Image {
                    id: img
                    source: domain+"/vi/"+id+"/mqdefault.jpg"
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
                            JS.addFavItem(list.model.get(index).id, list.model.get(index).title, list.model.get(index).service)
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
                            pageStack.push(Qt.resolvedUrl("YT.qml"), {videoId: list.model.get(index).id, name: list.model.get(index).title, mode: "audio"});
                        }
                    }
                    MenuItem {
                        text: qsTr("Open link externally")
                        onClicked: {
                            link = "https://youtube.com/watch?v="+list.model.get(index).id
                            Qt.openUrlExternally(link);
                        }
                    }

                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("YT.qml"), {videoId: list.model.get(index).id, name: list.model.get(index).title });
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
