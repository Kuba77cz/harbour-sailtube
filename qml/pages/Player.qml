import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

Page {
    id: page

    property string videoId
    property string videoUrl
    property string name

    Component.onCompleted: {
        indicatior.running = true
        //JS.deleteItemVI(videoId)
       	//JS.addItem(videoId,name,0)
	var domain = JS.getInvInstance()
        var url = domain+"/api/v1/videos/"+videoId
        console.log(url)
        JS.httpRequest("GET", url, processData)
        //video.play()
    }

    function processData(data) {
        var json = data;
        var obj = JSON.parse(json);
        //var ="";
	if (name === "" && obj.title.toString().length > 0) {
	    name = obj.title.toString();
	}

        if (obj.formatStreams && obj.formatStreams.length > 0) {
            videoUrl = obj.formatStreams[0].url // Nastavení první dostupné URL
	    JS.deleteItemVI(videoId)
            JS.addItem(videoId,name,0)
            video.source = videoUrl
            video.play()
        } else {
            console.log("No formats available")
        }

        indicatior.running = false
        //return r;
    }

    BusyIndicator {
        id: indicatior
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

        /*PullDownMenu {
            MenuItem {
                text: qsTr("1.25x")
                onClicked: video.playbackRate = 1.25;
            }
        }*/
        Video {
              id: video
              width : parent.width
              height : parent.height




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
