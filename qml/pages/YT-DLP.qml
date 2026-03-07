import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import io.thp.pyotherside 1.5
import "../components"
import "../main.js" as JS

Page {
    id: page

    //property string videoId
    property string name
    property string mode: "video"
    property string inputUrl
    property bool hasError: false
    property bool backendReady: false

    function showErrorPage(errText) {
        pageStack.push("ErrorPage.qml", {
                           errorText: errText
                       })
    }

    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../python"))
            importModule("backend", function() {
                backendReady = true
                console.log("✅ backend loaded")
                loadStream()
            })
            //JS.deleteItemVI(videoId)
            //JS.addItem(videoId, name, 0)
        }
    }

    Player {
        id: player
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Theme.itemSizeLarge * 2
        }
        title: name
        initialLoading: true

        property bool loadImage: mode === "audio"
    }

    ViewPlaceholder {
        enabled: page.hasError
        text: qsTr("Error loading video")
    }

    function loadStream() {
        if (!backendReady) {
            console.log("⏳ backend not ready yet")
            return
        }

        if (!inputUrl || inputUrl.length < 5) {
            console.log("⚠️ URL je prázdná nebo nevalidní")
            return
        }

        py.call("backend.get_stream_url",
                [inputUrl, "video"],
                function(res) {

                    if (!res) {
                        console.log("❌ backend returned undefined")
                        showErrorPage("yt-dlp error:\n\n"+res.error)
                        return
                    }

                    if (res.ok && res.url) {
                        console.log("🎬 stream url:", res.url)
                        player.source = res.url
                    } else {
                        console.log("❌ yt-dlp error:", res.error)
                        showErrorPage("yt-dlp error:\n\n"+res.error)
                        page.hasError = true
                    }
                })
    }
}
