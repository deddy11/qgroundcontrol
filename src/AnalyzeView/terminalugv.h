#ifndef TERMINALUGV_H
#define TERMINALUGV_H

#include <QObject>
#include <iostream>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>

class TerminalUGV : public QObject
{
    Q_OBJECT
public:
    explicit TerminalUGV(QObject *parent = nullptr);

public slots:
    void sendCommand(QString command);

    void openTerminal(void);

signals:

public slots:
};

#endif // TERMINALUGV_H
