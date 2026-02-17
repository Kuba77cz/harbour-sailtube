import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import io.thp.pyotherside 1.5
import "../components"
import "../main.js" as JS

Page {
    id: page

    property string videoId
    property string name
    property string mode

    property bool backendReady: false

    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../python"))
            importModule("backend", function() {
                backendReady = true
                console.log("✅ backend loaded")
                loadStream()
            })
            JS.deleteItemVI(videoId)
            JS.addItem(videoId, name, 0)
        }
    }

    Player {
        id: player
        anchors.fill: parent
        title: name
        initialLoading: true
    }

    function loadStream() {
        if (!backendReady) {
            console.log("⏳ backend not ready yet")
            return
        }

        py.call("backend.get_stream_url",
                ["https://youtube.com/watch?v=" + videoId, mode || "video"],
                function(res) {

                    if (!res) {
                        console.log("❌ backend returned undefined")
                        return
                    }

                    if (res.ok && res.url) {
                        player.source = res.url
                    } else {
                        console.log("❌ yt-dlp error:", res.error)
                    }
                })
    }
}
