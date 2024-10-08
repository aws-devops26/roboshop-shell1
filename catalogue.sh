#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.awssrivalli.online
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
fi
dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? " disabiling nodejs "

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? " enabiling nodejs:18 "

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? " installing node js "

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "adding user roboshop"
else
    echo -e " $G roboshop user already exist $Y SKIPPING $N "
fi


mkdir -p /app &>> $LOGFILE
VALIDATE $? " created app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? " downloading catalogue application"

cd /app 
unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? " unzipping catalogue"

npm install  &>> $LOGFILE
VALIDATE $? " installing dependencies"

cp /home/centos/roboshop-shell1/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? " copying catalogue service "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " catalogue demon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? " catalogue enabiling "

systemctl start catalogue &>> $LOGFILE
VALIDATE $? " catalogue start"

cp /home/centos/roboshop-shell1/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? " installing mongodb client"

mongo --host mongodb.awssrivalli.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "loading catalogue data into mongodb"