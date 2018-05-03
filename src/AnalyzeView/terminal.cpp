#include "terminal.h"
#include <iostream>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>

using namespace std;

Terminal::Terminal(QObject *parent) : QObject(parent)
{

}

void Terminal::sendCommand(QString command)
{
    int fd;
    char myfifo[] = "/tmp/myfifo";
    string command2 = command.toStdString();

    char *myfifo2 = myfifo;

    /* create the FIFO (named pipe) */
    mkfifo(myfifo2, 0666);

    /* write "Hi" to the FIFO */
    fd = open(myfifo2, O_WRONLY);
    write(fd, command2.c_str(), sizeof(command2.c_str()));
    close(fd);

    /* remove the FIFO */
    unlink(myfifo2);

    return;
}

void Terminal::openTerminal()
{

    pid_t pid = fork();
    if (pid == 0) {
        //kid
        system("gnome-terminal -x sh -c 'cd ~/Deddy/QGroundProject/CProgrammingCode; ./reader; exec bash'");
    }
    if (pid > 0) {
        //parent
        wait(0);
    }

    return;

}


