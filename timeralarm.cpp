#include "timeralarm.h"

#include <QDateTime>


#include <timed-qt5/event>
#include <timed-qt5/exception>

#include "alarminterface.h"


TimerAlarm::TimerAlarm(QObject *aParent) : QObject(aParent)
{
    m_id = 0;
}

TimerAlarm::TimerAlarm(int aAlarmIdQ, QObject *aParent) : TimerAlarm(aParent)
{
    m_id = aAlarmIdQ;
}

void TimerAlarm::setAlarm(int aTicker)
{
    Maemo::Timed::Event lEvent;
    QDBusPendingCallWatcher *lWatcher;
    QDateTime lNow;
    QDateTime lTriggerDateTime;
    int lTriggerTime;
    lEvent.setReminderFlag();
    lEvent.setAttribute(QLatin1String("APPLICATION"), QLatin1String("Timer"));
    lEvent.setAttribute(QLatin1String("TITLE"), QLatin1String("Timer"));
    lNow = QDateTime::currentDateTimeUtc();
    lTriggerDateTime = lNow.addSecs(aTicker);
	lTriggerTime = lTriggerDateTime.toTime_t();
    lEvent.setTicker(lTriggerTime);
	lEvent.setAlarmFlag();
	lEvent.setAttribute(QLatin1String("triggerTime"), QString::number(lTriggerTime));
	lEvent.setAttribute(QLatin1String("type"), QLatin1String("countdown"));
    if (m_id)
        lWatcher = new QDBusPendingCallWatcher(AlarmInterface::instance()->replace_event_async(lEvent, m_id), this);
    else
        lWatcher = new QDBusPendingCallWatcher(AlarmInterface::instance()->add_event_async(lEvent), this);
    connect(lWatcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(saveReply(QDBusPendingCallWatcher*)));
}

int TimerAlarm::getId()
{
    return m_id;
}

void TimerAlarm::setId(int aId)
{
    m_id = aId;
}

void TimerAlarm::saveReply(QDBusPendingCallWatcher *aWatcher)
{
    QDBusPendingReply<uint> lReply = *aWatcher;
    aWatcher->deleteLater();

    if (lReply.isError()) {
        qWarning() << "Timer: Cannot sync alarm:" << lReply.error();
        return;
    }

    m_id = lReply.value();
    emit saved();
}

void TimerAlarm::deleteAlarm()
{
    QDBusPendingCallWatcher *lWatcher;

    if (m_id) {
        QDBusPendingCall lCall = AlarmInterface::instance()->cancel_async(m_id);
        lWatcher = new QDBusPendingCallWatcher(lCall, this);
        connect(lWatcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(deleteReply(QDBusPendingCallWatcher*)));
        m_id = 0;
    }


}

void TimerAlarm::deleteReply(QDBusPendingCallWatcher *aWatcher)
{
    QDBusPendingReply<bool> lReply = *aWatcher;
    aWatcher->deleteLater();

    if (lReply.isError())
        qWarning() << "Nemo.Alarms: Cannot delete alarm from timed:" << lReply.error();
}
