#ifndef TERMINAL_H
#define TERMINAL_H

#include <QObject>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

class Terminal : public QObject
{
    Q_OBJECT
public:
    explicit Terminal(QObject *parent = nullptr);

public slots:
    void sendCommand(QString command);

    void openTerminal(void);

signals:

public slots:
};

#endif // TERMINAL_H
