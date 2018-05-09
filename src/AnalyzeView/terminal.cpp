#include "terminal.h"

using namespace std;

Terminal::Terminal(QObject *parent) : QObject(parent)
{

}

void Terminal::sendCommandUAV(QString command)
{
    int fd;
    char myfifo[] = "/tmp/UAVtemp";
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

void Terminal::openTerminalUAV()
{
//    int i = 1;
//    string systemCommand = "gnome-terminal -x sh -c 'cd ~/Deddy/QGroundProject/CProgrammingCode; ./executeUAV; exec sleep 2; exit'";

//    systemCommand.insert(81,to_string(i));
//    cout << systemCommand << endl;
    system("gnome-terminal -x sh -c 'cd ~/Deddy/QGroundProject/CProgrammingCode; ./executeUAV; exec sleep 2; exit'");

//    pid_t pid = fork();
//    if (pid == 0) {
//        //kid
//        system("gnome-terminal -x sh -c 'cd ~/Deddy/QGroundProject/CProgrammingCode; ./readerUAV; exec bash'");

//    }
//    if (pid > 0) {
//        //parent
//        wait(0);
//    }

    return;

}

void Terminal::sendCommandUGV(QString command)
{
    int fd;
    char myfifo[] = "/tmp/UGVtemp";
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

void Terminal::openTerminalUGV()
{
//    string systemCommand = "gnome-terminal -x sh -c 'cd ~/Deddy/QGroundProject/CProgrammingCode; ./executeUGV; exec sleep 2; exit'";
    system("gnome-terminal -x sh -c 'cd ~/Deddy/QGroundProject/CProgrammingCode; ./executeUGV; exec sleep 2; exit'");
}


