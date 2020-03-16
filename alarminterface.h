#ifndef ALARMINTERFACE_H
#define ALARMINTERFACE_H

#include <QObject>
#include <QTimer>
#include <QtGlobal>
#include <QMap>

#include <timed-qt5/interface>

class AlarmInterface : public Maemo::Timed::Interface
{
    Q_OBJECT
public:
    static AlarmInterface *instance();

signals:
    void alarmTriggersChanged(QMap<quint32, quint32>);

private slots:
    void alarmTriggersChanged(Maemo::Timed::Event::Triggers map);
    void processAlarmTriggers();

private:
    AlarmInterface();

    QMap<quint32,quint32> triggerMap;
    QTimer *timer;
};

#endif // ALARMINTERFACE_H
