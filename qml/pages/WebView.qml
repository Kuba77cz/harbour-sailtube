import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0

 Page {
    property string pageurl
    property string videoId
    allowedOrientations: Orientation.All
	
    PullDownMenu {
                    MenuItem {
                        text: qsTr("Otevřít externě")
                        onClicked: {
                            link = 
"https://youtube.com/watch?v="+videoId
                            Qt.openUrlExternally(link);
                        }
                    }
                    MenuItem {
                        text: qsTr("Otevřít externě pouze zvuk")
                        onClicked: {
                            link = 
"https://invidious.fdn.fr/watch?v="+videoId+"&listen=1"
                            Qt.openUrlExternally(link);
                        }
                    }

    }

    WebView {
         id: webView
	 anchors.fill: parent

         active: true
         anchors {
             top: parent.top
             left: parent.left
             right: parent.right
             bottom: parent.bottom
         }
         url: "https://yt.artemislena.eu/watch?v="+videoId
     }

 }
