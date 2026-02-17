import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import Nemo.DBus 2.0
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

Page {
    id: root

    property alias tabsModel: tabs.model
    property string name2
    property string url2
    property string extractedText
    property string inputUrl

    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        /*PullDownMenu {
            MenuItem {
                text: qsTr("Trending gaming")
                onClicked: pageStack.push(Qt.resolvedUrl("Trending.qml"), {type: "gaming"})
            }
            MenuItem {
                text: qsTr("Trending news")
                onClicked: pageStack.push(Qt.resolvedUrl("Trending.qml"), {type: "news"})
            }
            MenuItem {
                text: qsTr("Trending movies")
                onClicked: pageStack.push(Qt.resolvedUrl("Trending.qml"), {type: "movies"})
            }
            MenuItem {
                text: qsTr("Trending music")
                onClicked: pageStack.push(Qt.resolvedUrl("Trending.qml"), {type: "music"})
            }
            MenuItem {
                text: qsTr("yt-dlp player")
                onClicked: pageStack.push(Qt.resolvedUrl("SearchURL.qml"))
            }
        }*/


        TabView {
            id: tabs

            anchors.fill: parent
            currentIndex: 0

            header: TabBar {
                model: tabModel
            }

            model: [sr,srch,url,fv,hs]
            Component {
                id: sr
                TabItem {
                    flickable: srView.flickable
                    SR {
                        id: srView
                        //topMargin: tabs.tabBarHeight
                        //header: Item { width: 1; height: tabs.tabBarHeight + column.height }
                        Connections {
                            target: root
                            //onReset: _callHistoryView.reset()
                        }
                    }
                    VerticalScrollDecorator {}
                }
            }
            Component {
                id: srch
                TabItem {
                    flickable: srchView.flickable
                    SRCH {
                        id: srchView
                        //topMargin: tabs.tabBarHeight
                        //header: Item { width: 1; height: tabs.tabBarHeight + column.height }
                        Connections {
                            target: root
                            //onReset: _callHistoryView.reset()
                        }
                    }
                    VerticalScrollDecorator {}
                }
            }
            Component {
                id: url
                TabItem {
                    flickable: urlView.flickable
                    URL {
                        id: urlView
                        //topMargin: tabs.tabBarHeight
                        //header: Item { width: 1; height: tabs.tabBarHeight + column.height }
                        Connections {
                            target: root
                            //onReset: _callHistoryView.reset()
                        }
                    }
                    VerticalScrollDecorator {}
                }
            }

            Component {
                id: fv
                TabItem {
                    flickable: fv.flickable
                    FV {
                        id: fvView
                        //topMargin: tabs.tabBarHeight
                        //headerHeight: tabs.tabBarHeight + column.height
                        //isCurrentItem: parent.isCurrentItem
                        Connections {
                            target: root
                            //onReset: dialerView.reset()
                        }
                        VerticalScrollDecorator {}
                    }
                }
            }

            Component {
                id: hs
                TabItem {
                    flickable: hs.flickable
                    HS {
                        id: hsView
                        //topMargin: tabs.tabBarHeight
                        //headerHeight: tabs.tabBarHeight + column.height
                        //isCurrentItem: parent.isCurrentItem
                        Connections {
                            target: root
                            //onReset: dialerView.reset()
                        }
                        VerticalScrollDecorator {}
                    }
                }
            }
            /*Component {
                id: tr
                TabItem {
                    flickable: tr.flickable
                    TR {
                        id: trView
                        //topMargin: tabs.tabBarHeight
                        //headerHeight: tabs.tabBarHeight + column.height
                        //isCurrentItem: parent.isCurrentItem
                        Connections {
                            target: root
                            //onReset: dialerView.reset()
                        }
                        VerticalScrollDecorator {}
                    }
                }
            }*/

        }

        ListModel {
            id: tabModel

            ListElement {
                title: qsTr("Search video")
            }
            ListElement {
                title: qsTr("Search channel")
            }
            ListElement {
                title: qsTr("Load URL")
            }
            ListElement {
                title: qsTr("Favorites")
            }
            ListElement {
                title: qsTr("History")
            }
            /*ListElement {
                title: qsTr("Trending")
            }*/
        }
    }
}
