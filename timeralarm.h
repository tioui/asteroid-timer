#ifndef TIMER_ALARM_H
#define TIMER_ALARM_H

#include <QObject>
#include <QDBusPendingCallWatcher>
#include <timed-qt5/interface>

class TimerAlarm : public QObject
{
    Q_OBJECT
public:

    TimerAlarm(QObject *parent = NULL);
    TimerAlarm(int alarmIdQ, QObject *parent = NULL);
    Q_INVOKABLE void setAlarm(int ticker);
    Q_INVOKABLE void deleteAlarm();
    Q_INVOKABLE int getId();
    Q_INVOKABLE void setId(int id);
private:
    Maemo::Timed::Interface getTimedInterface();
    Maemo::Timed::Interface m_timedInterface;
    int m_id;

signals:
    void saved();

public slots:
    void saveReply(QDBusPendingCallWatcher *watcher);
    void deleteReply(QDBusPendingCallWatcher *watcher);
};

#endif // TIMER_ALARM_H
