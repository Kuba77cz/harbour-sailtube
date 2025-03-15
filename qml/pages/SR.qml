import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0

TabItem {
    id: sr

    property alias flickable: flickable
    property string id_txt
    property string text
    property int type

    function send() {
        switch (cbType.currentIndex)
        {
        case 0: type = 0; pageStack.push(Qt.resolvedUrl("Search.qml"), {query: sf.text }); break;
        //case 1: type = 1; pageStack.push(Qt.resolvedUrl("SearchChannel.qml"), {query: sf.text, type2: type }); break;
        case 1: pageStack.push(Qt.resolvedUrl("SearchPT.qml"), {query: sf.text }); break;
        //case 3: type = 3; break;
        default: type = 0; break;
        }
        //console.log(cbType.currentIndex)
    }
    
    anchors.fill: parent
    
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
        anchors.topMargin: 300//sr.height / 8

	SearchField {
                id: sf
                width: page.width

                anchors {
                    left: parent.left
                    right: parent.right
                }
                placeholderText: qsTr("Looking for ...")
                text: ""
                //inputMethodHints: Qt.ImhNoPredictiveText
                EnterKey.onClicked: {
                    send()
                }
            }
            ComboBox {
                //width: page.width
                anchors.top: sf.bottom
                label: "Service"
                id: cbType
                //currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: "Invidious" }
//                    MenuItem { text: "Channel" }
                    MenuItem { text: "PeerTube Archlinux.cz" }
                }
            }
        }
        
    }
