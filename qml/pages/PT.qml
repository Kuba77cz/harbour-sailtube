import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../main.js" as JS
import "../components"

Page {
    id: page

    property string videoId
    property string name
    property string mode

    Player {
        id: player
        anchors.fill: parent
        title: name
        initialLoading: true
        service: "1"
    }

    Component.onCompleted: {
        var baseUrl = "https://peertube.arch-linux.cz"
        var url = baseUrl + "/api/v1/videos/" + videoId
        JS.httpRequest("GET", url, function(data) {
            var obj = JSON.parse(data)
            if (mode === "audio") {
                player.source = obj.streamingPlaylists[0].files[3].playlistUrl
            } else {
                player.source = obj.streamingPlaylists[0].playlistUrl
            }
        })
        JS.deleteItemVI(videoId)
        JS.addItem(videoId, name, "1")
    }
}
