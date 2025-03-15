# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sailtube

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-sailtube.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AudioPlayer.qml \
    qml/pages/AudioPlayerPT.qml \
    qml/pages/ChannelLatest.qml \
    qml/pages/ChannelLatestPT.qml \
    qml/pages/FV.qml \
    qml/pages/HS.qml \
    qml/pages/Player.qml \
    qml/pages/PlayerPT.qml \
    qml/pages/Search.qml \
    qml/pages/SearchPT.qml \
    qml/pages/SearchChannel.qml \
    qml/pages/SearchChannelPT.qml \
    qml/pages/SR.qml \
    qml/pages/SRCH.qml \
    qml/pages/TR.qml \
    qml/pages/Trending.qml \
    qml/pages/WebView.qml \
    rpm/harbour-sailtube.changes.in \
    rpm/harbour-sailtube.changes.run.in \
    rpm/harbour-sailtube.spec \
    translations/*.ts \
    harbour-sailtube.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
# TRANSLATIONS += translations/harbour-sailtube-de.ts
