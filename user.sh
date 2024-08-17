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

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? " downloading user application"

cd /app 
unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? " unzipping user"

npm install  &>> $LOGFILE
VALIDATE $? " installing dependencies"

cp /home/centos/roboshop-shell1/user.service /etc/systemd/system/user.service
VALIDATE $? " copying user service "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " user demon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? " user enabiling "

systemctl start user &>> $LOGFILE
VALIDATE $? " user starting"

cp /home/centos/roboshop-shell1/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? " installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> LOGFILE
VALIDATE $? "loading user data into mongodb"