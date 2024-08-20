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

dnf install python36 gcc python3-devel -y 
VALIDATE $? "installing python36 gcc python 3"

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

curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? " downloading payment application"

cd /app 
unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? " unzipping payment"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE

cp payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? " copying payment service "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " payment demon reload"

systemctl enable payment &>> $LOGFILE
VALIDATE $? " payment enabiling "

systemctl start payment &>> $LOGFILE
VALIDATE $? " payment starting"

