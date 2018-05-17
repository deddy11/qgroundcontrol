#ifndef TERMINAL_H
#define TERMINAL_H

#include <QObject>
#include <iostream>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>

class Terminal : public QObject
{
    Q_OBJECT
public:
    explicit Terminal(QObject *parent = nullptr);

public slots:
    void sendCommandUAV(QString command);
    void openTerminalUAV(void);
    void sendCommandUGV(QString command);
    void openTerminalUGV(void);

signals:
};

#endif // TERMINAL_H
