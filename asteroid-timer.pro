TARGET = asteroid-timer
CONFIG += asteroidapp link_pkgconfig

PKGCONFIG += asteroidapp Qt5DBus timed-qt5 timed-voland-qt5

SOURCES += main.cpp \
    timeralarm.cpp \
    alarminterface.cpp

HEADERS += \
    timeralarm.h \
    alarminterface.h

RESOURCES +=   resources.qrc
OTHER_FILES += main.qml

lupdate_only{ SOURCES += i18n/asteroid-timer.desktop.h }
TRANSLATIONS = $$files(i18n/$$TARGET.*.ts)
