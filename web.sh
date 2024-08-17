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
fi

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? " nginx enabiling "

systemctl start nginx  &>> $LOGFILE
VALIDATE $? "nginx starting"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? " Removing the default content that web server is serving."

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Download the frontend content"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "Extract the frontend content"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "Extract the frontend content"

cp /home/centos/roboshop-shell1/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "Create Nginx Reverse Proxy Configuration"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? " restarting nginx server"
