import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import Nemo.DBus 2.0
import "main.js" as JS
import "cover"

ApplicationWindow {
    id: app
    //property var coverPlayer

    DBusAdaptor {
        service: "cz.kuba77.SailTube"
        iface: "cz.kuba77.SailTube"
        path: "/cz/kuba77/SailTube"
        xml: '\
     <interface name="cz.kuba77.sailtube">
       <method name="openPage">
         <arg name="page" type="s" direction="in">
           <doc:doc>
             <doc:summary>
               Name of the page to open

(https://github.com/mentaljam/harbour-osmscout/tree/master/qml/pages)
             </doc:summary>
           </doc:doc>
         </arg>
         <arg name="arguments" type="a{sv}" direction="in">
           <doc:doc>
             <doc:summary>
               Arguments to pass to the page
             </doc:summary>
           </doc:doc>
         </arg>
       </method>
       <method name="openUrl">
         <arg name="url" type="s" direction="in">
           <doc:doc>
             <doc:summary>
               url of map service
             </doc:summary>
           </doc:doc>
         </arg>
       </method>
     </interface>'

        function processData(data, videoId) {
            try {
                var obj = JSON.parse(data)
                var name2 = obj.title ? obj.title.toString() : ""

                pageStack.push(Qt.resolvedUrl("pages/YT.qml"), {
                                   videoId: videoId,
                                   name: name2,
                                   mode: "video"
                               })

            } catch (e) {
                console.log("JSON parse error:", e)
            }
        }


        function isUrl(link) {
            if (!link)
                return false;

            var str = link.toString().trim();
            return str.indexOf("http://") === 0 || str.indexOf("https://") === 0;
        }

        function isYoutubeUrl(link) {
            if (!link)
                return false;

            var str = link.toString().trim().toLowerCase();

            var ytRegex = /^(https?:\/\/)?(www\.|m\.)?(youtube\.com|youtu\.be)\//;

            return ytRegex.test(str);
        }

        function extractYoutubeId(url) {
            if (!isYoutubeUrl(url))
                return null;

            var str = url.toString().trim();

            // Striktní regex – jen platné YouTube ID
            var regex = /^(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com|youtu\.be)\/(?:watch\?(?:.*&)?v=|embed\/|v\/|shorts\/|youtu\.be\/)?([A-Za-z0-9_-]{11})(?=$|[?&\/#])/i;

            var match = str.match(regex);

            return match ? match[1] : null;
        }


        function extractTextAfterEquals(inputString) {
            // Convert to string if not already
            var str = inputString.toString();
            var parts = str.split('=');
            if (parts.length > 1) {
                return parts[1];
            } else {
                return "";
            }
        }

        function openUrl(url) {
            __silica_applicationwindow_instance.activate()

            if (!isUrl(url)) {
                console.log("Not a valid URL");
                return;
            }

            var videoId = extractYoutubeId(url)

            if (videoId) {
                //var apiUrl = JS.getInvInstance() + "/api/v1/videos/" + videoId
                /*JS.httpRequest("GET", apiUrl, function(data) {
                    processData(data, videoId)
                })*/
                pageStack.push(Qt.resolvedUrl("pages/YT.qml"), {
                                   videoId: videoId,
                                   name: "",
                                   mode: "video"
                               })

            } else {
                pageStack.push(Qt.resolvedUrl("pages/YT-DLP.qml"),
                               { inputUrl: url.toString() })
            }
        }

        function openPage(page, arguments) {
            __silica_applicationwindow_instance.activate()
            console.log("D-Bus: activate page " + page + "
(current: " + pageStack.currentPage.objectName + ")");
            if ((page === "Tracker" || page === "Downloads") &&
                    page !== pageStack.currentPage.objectName) {
                pageStack.push(Qt.resolvedUrl("%1.qml".arg(page)),
                               arguments)
            }
        }
    }

    initialPage: Component { MainPage { } }
    cover: CoverPage {
        id: coverPage
        //player: coverPlayer
    }

    allowedOrientations: defaultAllowedOrientations
}
