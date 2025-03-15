import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

Page {
    id: page

    property string videoId
    property string name
    property string link

    Component.onCompleted: {
        indicator.running = true
        var url = "https://peertube.arch-linux.cz/api/v1/videos/"+videoId
        console.log(url)
        JS.httpRequest("GET", url, processData)                        
	JS.deleteItemVI(videoId)
	JS.addItem(videoId,name,"1")
        //video.play()
        indicator.running = false
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
//        console.log(data)
        var link="";
        link = obj.streamingPlaylists[0].playlistUrl
        console.log(link) 
        video.source = link
        video.play()
    }

    BusyIndicator {
        id: indicator
        running: false
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView
        model: 20
        anchors.fill: parent
        header: PageHeader {
            title: name
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("1.25x")
                onClicked: video.playbackRate = 1.25;
            }
        }


        Video {
              id: video
              width : parent.width
              height : parent.height
//              source: link
//"https://yt.artemislena.eu/latest_version?id="+videoId+"&itag=22"

	   /*   onPositionChanged: {
              // Update the slider position whenever the video's position changes
            		slider.value = video.position;
	      }
*/
	  /*  Timer {
	        interval: 100 // Update every 100 milliseconds
        	running: video.playbackState === MediaPlayer.PlayingState

        	onTriggered: {
            		slider.value = video.position / video.duration;
        	}
    	}*/

              MouseArea {
                  anchors.fill: parent
                  onClicked: {
                      video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play()
                  }
              }

              focus: true
              Keys.onSpacePressed: video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play()
              Keys.onLeftPressed: video.seek(video.position - 5000)
              Keys.onRightPressed: video.seek(video.position + 5000)
          }
        /*Slider {
                id: slider
		width: parent.width
		//height: 40
		//anchors.top: video.bottom + 100
		//from: 0
		//to: 1
		value: video.position / video.duration

        	onValueChanged: {
            		video.seek(slider.value * video.duration)
        	}
        }*/
   

	/*Button {
	  onClicked: video.playbackState === MediaPlayer.PlayingState ? video.pause() : video.play()
	  anchors.top:  
          anchors.horizontalCenter: parent.horizontalCenter
	}*/

        VerticalScrollDecorator {}
    }
}
