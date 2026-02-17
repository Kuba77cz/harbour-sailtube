import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string errorText: ""

    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Copy text to clipboard")
                onClicked: Clipboard.text = page.errorText
            }
        }

        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: "Error log"
            }


            Text {
                text: page.errorText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 40
                    rightMargin: 40
                }
            }

        }
    }
}
