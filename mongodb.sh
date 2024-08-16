#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo -e "$Y script started executing at $N $TIMESTAMP" &>> $LOGFILE
VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e " $2 ....$R FAILED $N "
        exit 1
    else
        echo -e " $2......$G SUCCESS $N "
    fi
}
if [ $ID -ne 0 ]
then
    echo -e " $R ERROR :: please run with root access $N "
    exit 1
else    
    echo -e " $G u r root user $N "
fi
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? " copied mongodb repo"
dnf install mongodb-org -y  &>> $LOGFILE
VALIDATE $? " installing mongodb "
systemctl enable mongod &>> $LOGFILE
VALIDATE $? " enabiling mongodb"
systemctl start mongod &>> $LOGFILE
VALIDATE $? " starting mongodb "
$sed -i 's/127.0.0.1 to 0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? " editing remote access to mongodb"
systemctl restart mongod &>> $LOGFILE
VALIDATE $? " restarting mongodb"
