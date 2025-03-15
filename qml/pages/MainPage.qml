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

    /*function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        name2 = obj.title.toString();
        console.log(name2);
	//callback(name2);
        //pageStack.push(Qt.resolvedUrl("Player.qml"), { 
videoId: extractedText, name: name2 });
    }*/

    DBusAdaptor {
        service: "cz.kuba77.harbour-sailtube"
        iface: "cz.kuba77.harbour-sailtube"
        path: "/cz/kuba77/SailTube"
        xml: '\
     <interface name="cz.kuba77.harbour-sailtube">
       <method name="openPage">
         <arg name="page" type="s" direction="in">
           <doc:doc>
             <doc:summary>
               Name of the page to open
               
(https://github.com/mentaljam/harbour-osmscout/tree/master/qml/pages)
             </doc:summary>
           </doc:doc>
         </arg>
         <arg name="arguments" type="a{sv}" direction="in">
           <doc:doc>
             <doc:summary>
               Arguments to pass to the page
             </doc:summary>
           </doc:doc>
         </arg>
       </method>
       <method name="openUrl">
         <arg name="url" type="s" direction="in">
           <doc:doc>
             <doc:summary>
               url of map service
             </doc:summary>
           </doc:doc>
         </arg>
       </method>
     </interface>'

    function extractTextAfterEquals(inputString) {
        // Convert to string if not already
        var str = inputString.toString();
        var parts = str.split('=');
        if (parts.length > 1) {
            return parts[1];
        } else {
            return "";
        }
    }

       function openUrl(url) {
           var urlStr = url + "";
           var extractedText = "";
//           console.log("open url: " + url);
           __silica_applicationwindow_instance.activate()
                   // go to location and even open its details...
                   //map.showCoordinates(lat, lon);
           var youtubeLink = url.toString();
           console.log("Type of youtubeLink:", typeof youtubeLink);
           //var link = youtubeLink;
/*           if (youtubeLink.indexOf("youtu.be") !== -1) {
                // Extract string after the last '/'
                extractedText = youtubeLink.split("/").pop();
           } else {
                extractedText = extractTextAfterEquals(youtubeLink);
           }
*/
           var videoIdMatch = 
youtubeLink.match(/(?:\?v=|\/embed\/|\/\d\/|\/vi\/|\/e\/|youtu\.be\/|\/v\/|\/watch\?v=|&v=|&vi=|v=|\/d\/|\/u\/\d\/|\/user\/[^\/]+\/[^\/]+\/|\/YTS(?:\/)?\w?\/?|\/v2\/watch\?v=)([^"&?\/\s]{11})/);
           var videoId = videoIdMatch ? videoIdMatch[1] : notYT(youtubeLink);
           extractedText = videoId
           JS.deleteItemVI(videoId)
           url2 = JS.getInstance()+"/api/v1/videos/"+videoId
	   /*JS.httpRequest("GET", url2, function(response) {
                            var name2 = processData(response);
                            console.log(name2);
                            pageStack.push(Qt.resolvedUrl("Player.qml"), {
                                videoId: videoId,
                                name: name2
                            });
                        });*/

           //JS.httpRequest("GET", url2, processData)
           //console.log(name2);
	   pageStack.push(Qt.resolvedUrl("Player.qml"),{videoId: extractedText })
           /*if (name2 !== "") {
		pageStack.push(Qt.resolvedUrl("Player.qml"),{videoId: extractedText, name: name2 })
	   } else {
		console.log(name2);
	   }*/
       }

       function notYT(link) {
           //var url = "https://arch-linux.cz/w/nvBuFGYwErFHc2tfhwU14r";
           var link2 = link.split("w/")[1];

           console.log(link2);
           pageStack.push(Qt.resolvedUrl("Playertest.qml"),{videoId: link2, name: ""})

       }

       function openPage(page, arguments) {
           __silica_applicationwindow_instance.activate()
           console.log("D-Bus: activate page " + page + " 
(current: " + pageStack.currentPage.objectName + ")");
           if ((page === "Tracker" || page === "Downloads") && 
page !== pageStack.currentPage.objectName) {
               pageStack.push(Qt.resolvedUrl("%1.qml".arg(page)), 
arguments)
           }
       }
    }

    SilicaFlickable {
        anchors.fill: parent
        
        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
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
                text: qsTr("Trending")
                onClicked: pageStack.push(Qt.resolvedUrl("Trending.qml"), {type: ""})
            }
        }


        TabView {
            id: tabs

            anchors.fill: parent
            currentIndex: 0

            header: TabBar {
                model: tabModel
            }

            model: [sr,srch,fv,hs]
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
