import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import "../main.js" as JS

Item {
    id: root

    property string source: ""
    property string title: ""
    property bool isFullscreen: false
    property bool shouldAutoPlay: true
    property bool initialLoading: true
    property string service: ""

    property bool statusRunning: player.status === MediaPlayer.Loading
                                 || player.status === MediaPlayer.Buffering
                                 || initialLoading

    function formatTime(ms) {
        if (!ms || ms <= 0) return "0:00"
        var s = Math.floor(ms / 1000)
        var m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    /*Component.onCompleted: {
        var win = pageStack.window
        if (win) {
            win.coverPlayer = player
            if (win.coverPage) {
                win.coverPage.updatePlayer(player)   // teď Cover ví o playeru
            }
        }
    }*/

    BusyIndicator {
        id: busy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: statusRunning
        visible: statusRunning
    }

    Connections {
        target: player
        onStatusChanged: {
            if (player.status === MediaPlayer.Playing ||
                    player.status === MediaPlayer.Stopped) {
                root.initialLoading = false
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: Theme.paddingSmall

        PageHeader {
            title: root.title
            visible: !root.isFullscreen
        }

        Video {
            id: player
            width: parent.width
            height: root.isFullscreen ? parent.height : parent.height * 0.45
            source: root.source
            autoPlay: false
            visible: mode !== "audio"

            property bool controlsVisible: false

            Timer {
                id: hideTimer
                interval: 2500
                repeat: false
                onTriggered: {
                    if (player.playbackState === MediaPlayer.PlayingState)
                        player.controlsVisible = false
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    player.controlsVisible = true
                    hideTimer.restart()

                    player.playbackState === MediaPlayer.PlayingState
                            ? player.pause()
                            : player.play()
                }
            }

            // 🔘 Overlay button
            Item {
                anchors.centerIn: parent
                visible: player.controlsVisible
                Behavior on opacity { FadeAnimation {} }
                opacity: visible ? 1 : 0

                Image {
                    anchors.centerIn: parent
                    width: Theme.iconSizeExtraLarge
                    height: width
                    source: player.playbackState === MediaPlayer.PlayingState
                            ? "image://theme/icon-m-pause"
                            : "image://theme/icon-m-play"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        player.playbackState === MediaPlayer.PlayingState
                                ? player.pause()
                                : player.play()

                        player.controlsVisible = true
                        hideTimer.restart()
                    }
                }
            }

            Keys.onLeftPressed: player.seek(player.position - 5000)
            Keys.onRightPressed: player.seek(player.position + 5000)
            onSourceChanged: {
                if (root.shouldAutoPlay && source !== "") {
                    root.initialLoading = true
                    play()
                }
            }

            onPlaybackStateChanged: {
                if (playbackState === MediaPlayer.PlayingState) {
                    root.initialLoading = false
                }
            }

            onDurationChanged: {
                if (duration > 0) {
                    root.initialLoading = false
                    if (root.shouldAutoPlay) {
                        root.shouldAutoPlay = false
                        play()
                    }
                }
            }

        }
        Image {
            id: thumbnail
            //        anchors.fill: parent
            visible: mode === "audio"
            // JS.httpRequest("GET", "https://peertube.arch-linux.cz/api/v1/videos/"+videoId, function(response) { JS.processData(response, thumbnail);})
            source: service==="1" ? "" : JS.getInvInstance()+"/vi/" + videoId + "/maxres.jpg"
            fillMode: Image.PreserveAspectFit
            width: parent.width
            height: parent.height * 0.45




            MouseArea {
                anchors.fill: parent
                onClicked: {
                    player.controlsVisible = true
                    hideTimer.restart()
                    player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                }
            }

            // 🔘 Overlay button
            Item {
                anchors.centerIn: parent
                visible: player.controlsVisible
                Behavior on opacity { FadeAnimation {} }
                opacity: visible ? 1 : 0

                Image {
                    anchors.centerIn: parent
                    width: Theme.iconSizeExtraLarge
                    height: width
                    source: player.playbackState === MediaPlayer.PlayingState
                            ? "image://theme/icon-m-pause"
                            : "image://theme/icon-m-play"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        player.playbackState === MediaPlayer.PlayingState
                                ? player.pause()
                                : player.play()

                        player.controlsVisible = true
                        hideTimer.restart()
                    }
                }
            }


        }
    }

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: {
            if (!seekSlider.pressed)
                seekSlider.value = player.position
        }
    }

    Item {
        id: controls
        visible: !root.isFullscreen
        width: parent.width

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Theme.paddingLarge * 1.5

        Label {
            id: time1
            text: formatTime(player.position)
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
        }

        Slider {
            id: seekSlider
            width: parent.width
                   - time1.implicitWidth
                   - time2.implicitWidth
                   - 2 * Theme.paddingMedium
                   - 2 * Theme.horizontalPageMargin

            anchors.left: time1.right
            anchors.right: time2.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            anchors.verticalCenter: parent.verticalCenter

            minimumValue: 0
            maximumValue: player.duration > 0 ? player.duration : 1
            value: player.position

            onPressedChanged: {
                if (!pressed)
                    player.seek(value)
            }
        }

        Label {
            id: time2
            text: formatTime(player.duration)
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
