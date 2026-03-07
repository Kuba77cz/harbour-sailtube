import QtQuick 2.0
import Sailfish.Silica 1.0
import "../main.js" as JS

Page {
    id: page
    property string query
    property string link
    //property string userRegion: Qt.locale().name.split("_")[1] || "US" // eg. "CZ" or fallback "US"
    property string domain: JS.getInvInstance()

    function showErrorPage(errText) {
        pageStack.push("ErrorPage.qml", {
                           errorText: errText
                       })
    }

    Component.onCompleted: {
        indicatior.running = true
        var url;
        //var region = userRegion || "US";
        url = domain+"/search?q="+query+"&page=1&date=none&type=channel&duration=none&sort=relevance"
        console.log(url)
        JS.httpRequest("GET", url, processData)
    }


    function processData(status, data) {
        if (status !== 200) {
            console.log("HTTP ERROR")
            indicatior.running = false
            return
        }

        var html = data
        var blocks = html.split('<div class="h-box">')

        for (var i = 1; i < blocks.length; i++) {
            var block = blocks[i]

            var idMatch = block.match(/href="\/channel\/([^"]+)"/)
            var nameMatch = block.match(/class="channel-name"[^>]*>([^<]+)/)
            var imgMatch = block.match(/<img[^>]+src="([^"]+)"/)

            if (!idMatch || !nameMatch)
                continue

            var id = idMatch[1].toString()
            var name = nameMatch[1].toString().trim()
            name = name.replace(/<[^>]+>/g, "")
            .replace(/&nbsp;/g, " ")
            .replace(/\s+/g, " ")
            .trim()
            var thumb = imgMatch ? imgMatch[1].toString() : ""

            // Qt 5.6 safe check místo startsWith
            if (thumb.indexOf("/") === 0)
                thumb = domain +"/" + thumb

            myJSModel.append({
                                 "id": id,
                                 "author": name,
                                 "thumbnail": thumb
                             })
        }

        indicatior.running = false
        //        return r;
    }

    /*    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        var r="";
        for(var i = 0; i < obj.length; i++) {
            r = { "id": obj[i].authorId, "author": obj[i].author, "thumbnail": "https:"+obj[i].authorThumbnails[3].url }
            myJSModel.append(r)
        }

        indicatior.running = false
        return r;
    }
*/

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
                contentHeight: Theme.itemSizeMedium

                Image {
                    id: img
                    source: thumbnail
                    width: Theme.iconSizeLarge - 10
                    height: Theme.iconSizeLarge - 10
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                }

                Label {
                    text: author
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

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ChannelLatest.qml"), {authorId: list.model.get(index).id, authorName: list.model.get(index).author});
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
