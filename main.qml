/*
 * Copyright (C) 2016 - Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 - Florent Revest <revestflo@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import org.asteroid.controls 1.0
import Nemo.Ngf 1.0
import Nemo.DBus 2.0
import Nemo.KeepAlive 1.1
import Nemo.Configuration 1.0
import Nemo.Time 1.0
import TimerAlarm 1.0

Application {
    id: app

    centerColor: "#E34FB1"
    outerColor: "#83155B"

    ConfigurationValue {
        id: startDateConf
        key: "/timer/startDate"
        defaultValue: -1
    }

    ConfigurationValue {
        id: selectedTimeConf
        key: "/timer/selectedTime"
        defaultValue: -1
    }

    ConfigurationValue {
        id: runningConf
        key: "/timer/running"
        defaultValue: false
    }

    ConfigurationValue {
        id: alarmIdConf
        key: "/timer/alarmId"
        defaultValue: 0
    }

    property var startDate: 0
    property int selectedTime: 0
    property int seconds: 5*60

    function zeroPad(n) {
        return (n < 10 ? "0" : "") + n
    }

    TimerAlarm {
        id:timerAlarm
        onSaved: alarmIdConf.value = timerAlarm.getId()
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: Dims.h(70)
        Spinner {
            id: hourLV
            currentIndex: 0
            enabled: !timer.running
            height: parent.height
            width: Dims.w(20)
            model: 10
            delegate: SpinnerDelegate { text: index }
            onCurrentIndexChanged: if(enabled) seconds = secondLV.currentIndex + 60*minuteLV.currentIndex + 3600*hourLV.currentIndex
        }

        Label {
            text: ":"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            width: Dims.w(20)
            font.pixelSize: Dims.l(12)
        }

        Spinner {
            id: minuteLV
            currentIndex: 5
            enabled: !timer.running
            height: parent.height
            width: Dims.w(20)
            model: 60
            highlightMoveDuration: currentIndex != 0 ? 400 : 0
            onCurrentIndexChanged: if(enabled) seconds = secondLV.currentIndex + 60*minuteLV.currentIndex + 3600*hourLV.currentIndex
        }

        Label {
            text: ":"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            width: Dims.w(20)
            font.pixelSize: Dims.l(12)
        }

        Spinner {
            id: secondLV
            currentIndex: 0
            enabled: !timer.running
            height: parent.height
            width: Dims.w(20)
            model: 60
            highlightMoveDuration: currentIndex != 0 ? 400 : 0
            onCurrentIndexChanged: if(enabled) seconds = secondLV.currentIndex + 60*minuteLV.currentIndex + 3600*hourLV.currentIndex
        }
    }

    IconButton {
        id: iconButton
        iconName: timer.running ? "ios-pause" : "ios-timer-outline"
        visible: seconds !== 0

        onClicked: {
            if(timer.running)
            {
                timer.stop()
                runningConf.value = false
                timerAlarm.deleteAlarm()
            }
            else
            {
                startDate = new Date
                startDateConf.value = startDate.toLocaleString()
                selectedTime = seconds
                timerAlarm.setAlarm(seconds)
                selectedTimeConf.value = selectedTime
                runningConf.value = true
                timer.start()
            }
        }
    }

    NonGraphicalFeedback {
        id: feedback
        event: "alarm"
    }

    property DBusInterface _dbus: DBusInterface {
        id: dbus

        service: "com.nokia.mce"
        path: "/com/nokia/mce/request"
        iface: "com.nokia.mce.request"

        bus: DBus.SystemBus
    }

    function updateTime() {
        var currentDate = new Date
        seconds = selectedTime - ((currentDate.getTime() - startDate.getTime())/1000)
        if (seconds < 0){
            seconds = 0
        }
        secondLV.currentIndex = seconds%60
        minuteLV.currentIndex = (seconds%3600)/60
        hourLV.currentIndex = seconds/3600
    }

    function resetTime() {
        secondLV.currentIndex = 0
        minuteLV.currentIndex = 5
        hourLV.currentIndex = 0
    }

    Timer {
        id: timer
        running: false
        repeat: true
        interval: 500
        triggeredOnStart: true
        onTriggered: {
            if(seconds <= 0){
                runningConf.value = false
                Qt.callLater(Qt.quit)
            } else {
                updateTime()
            }
        }
        onRunningChanged: DisplayBlanking.preventBlanking = running
    }
    Component.onCompleted: {
        if (runningConf.value)
        {
            if (startDateConf.value !== -1)
            {
                startDate = Date.fromLocaleString(startDateConf.value)
                if (selectedTimeConf.value !== -1)
                {
                    selectedTime = selectedTimeConf.value
                    if (alarmIdConf.value !== 0)
                    {
                        timerAlarm.setId(alarmIdConf.value)
                        updateTime()
                        if (seconds <= 0){
                            resetTime()
                            timerAlarm.deleteAlarm()
                        }else{
                            timer.start()
                        }


                    }
                }
            }
        }
    }


}
