#include "alarminterface.h"


AlarmInterface::AlarmInterface()
{
    timer = new QTimer(this);
    timer->setSingleShot(true);
    timer->setInterval(500);
    connect(timer, SIGNAL(timeout()), this, SLOT(processAlarmTriggers()));
    alarm_triggers_changed_connect(this, SLOT(alarmTriggersChanged(Maemo::Timed::Event::Triggers)));
}

void AlarmInterface::alarmTriggersChanged(Maemo::Timed::Event::Triggers map)
{
    triggerMap = map;

    // Delay forwarding changed triggers, timed may emit alarm_triggers_changed
    // signals in rapid succession
    timer->start();
}

void AlarmInterface::processAlarmTriggers()
{
    emit alarmTriggersChanged(triggerMap);
}

AlarmInterface *AlarmInterface::instance()
{
    static AlarmInterface *timed = 0;
    if (!timed)
        timed = new AlarmInterface;
    return timed;
}
