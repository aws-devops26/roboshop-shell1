#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo -e "$Y script started executing at $N $TIMESTAMP " &>> $LOGFILE

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e " $2....$R  FAILED $N "
        exit 1
    else
        echo -e " $2.... $G SUCCESS $N "
    fi
}
if [ $ID -ne 0 ]
then
    echo -e " $R ERROR:: please run eith root access $N "
    exit 1
else
    echo -e " $G u r root use $N "


curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
VALIDATE $? " downloading erlang script" &>> $LOGFILE


curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
VALIDATE $? "downloading rabbitmq script" &>> $LOGFILE


dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "installing rabbitmq server"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "enabiling rabbitmq server"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "adding user roboshop,roboshop123"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "setting permission"