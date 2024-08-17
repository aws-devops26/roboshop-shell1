#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.awssrivalli.online
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "script started executing at $TIMESTAMP " &>> $LOGFILE
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

useradd roboshop &>> $LOGFILE
VALIDATE $? "adding user roboshop"

mkdir /app &>> $LOGFILE
VALIDATE $? " created app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? " downloading catalouge application"

cd /app 
unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? " unzipping catalouge"

npm install  &>> $LOGFILE
VALIDATE $? " installing dependencies"

cp /devops/repos/roboshop-shell1/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? " copying catalouge service "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " catalouge demon reload"

systemctl enable catalouge &>> $LOGFILE
VALIDATE $? " catalouge enabiling "

systemctl start catalouge &>> $LOGFILE
VALIDATE $? " catalouge start"

cp /devops/repos/roboshop-shell1/mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? " copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? " installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> LOGFILE
VALIDATE $? "loading catalouge data into mongodb"





