import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import QtQuick.LocalStorage 2.0
import "../main.js" as JS

TabItem {
    id: tr

    property alias flickable: flickable
    property string id_txt
    property string text
    //property int type
    property string imageurl
    property string authorId
    property string link
    property string authorName
    property string type

    
    property var trtype: ["general", "music", "movies", "news", "gaming"]

    // ListModel pro každou sekci, předdefinováno v QML
    ListModel { id: generalModel }
    ListModel { id: musicModel }
    ListModel { id: moviesModel }
    ListModel { id: newsModel }
    ListModel { id: gamingModel }

    // Vložení všech modelů do seznamu
    property var models: [generalModel, musicModel, moviesModel, newsModel, gamingModel]

    anchors.fill: parent

    function refresh() {
        indicatior.running = true
        var domain = JS.getInvInstance()

        // Vyprázdnění předchozích dat v modelech
        for (var i = 0; i < models.length; i++) {
            models[i].clear()
        }

        // Načtení dat pro každou kategorii
        for (var i = 0; i < trtype.length; i++) {
            var sectionIndex = i;  // Potřebujeme pro uzavření (closure)
            var model = models[sectionIndex];  // Vybereme správný model pro kategorii

            // URL pro danou kategorii
            var url = domain + "/api/v1/trending?region=CZ&type=" + trtype[sectionIndex];
            console.log("Fetching data for: " + trtype[sectionIndex] + " with URL: " + url)

            // HTTP request pro načtení dat
            JS.httpRequest("GET", url, function(data) {
                processData(data, model);
            });
        }
    }

    function processData(data, model) {
        var obj = JSON.parse(data);

        // Přidání načtených dat do modelu
        for (var i = 0; i < obj.length; i++) {
            var r = {
                "id": obj[i].videoId,
                "title": obj[i].title,
                "authorName": obj[i].author
            }
            model.append(r);
        }

        indicatior.running = false;
    }

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

        ExpandingSectionGroup {
            currentIndex: 0

            Repeater {
                model: trtype.length

                ExpandingSection {
                    id: section
                    property int sectionIndex: model.index  // Odpovídá položkám v `trtype`
                    title: "Trending " + trtype[sectionIndex]

                    // Použití content.sourceComponent pro dynamické přiřazení obsahu
                    content.sourceComponent: Component {
                        SilicaListView {
                            model: models[sectionIndex]  // Model odpovídající dané sekci

                            delegate: ListItem {
                                width: parent.width
                                contentHeight: Theme.itemSizeExtraLarge

                                Image {
                                    id: img
                                    source: "https://invidious.fdn.fr/vi/" + model.id + "/mqdefault.jpg"
                                    width: Theme.iconSizeExtraLarge
                                    height: Theme.iconSizeExtraLarge
                                    fillMode: Image.PreserveAspectFit
                                    anchors {
                                        left: parent.left
                                        leftMargin: Theme.horizontalPageMargin
                                        verticalCenter: parent.verticalCenter
                                    }
                                }

                                Label {
                                    text: model.title + "\n" + model.authorName
                                    width: parent.width - img.width - Theme.horizontalPageMargin * 2
                                    anchors {
                                        left: img.right
                                        verticalCenter: parent.verticalCenter
                                        right: parent.right
                                        rightMargin: Theme.horizontalPageMargin
                                    }
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                }

                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("Player.qml"), { videoId: model.id, name: model.title });
                                }
                            }
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            refresh();  // Načtení dat po spuštění komponenty
        }
    }
}

