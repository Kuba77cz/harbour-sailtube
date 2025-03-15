import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Rectangle {
    id: box
    antialiasing: true
    radius: 10
    property alias color: box.color
    property alias iconSource: image.source
    property alias soundSource: sound.source
    property bool pauseState: false
    onPauseStateChanged: {
        if(!pauseState)
            video.play();
        else
            video.pause();
    }
    Image {
        id: image
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectFit
    }

    Video {
        id: video

    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            if (video.playbackState != Video.PlayingState) {
                video.play();
            } else {
                video.pause();
            }
        }

    }
}
