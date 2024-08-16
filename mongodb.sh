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
        echo -e " $1......$G SUCCESS $N "
    fi
}
if [ $? -ne 0 ]
then
    echo -e " $R ERROR :: please run with root access $N "
    exit 1
else    
    echo -e " $G u r root user $N "
fi
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? " copied mongodb repo"
