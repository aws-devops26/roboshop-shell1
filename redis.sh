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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y  &>> $LOGFILE
VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? " enabiling redis "

dnf install redis -y &>> $LOGFILE
VALIDATE $? " installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf  &>> $LOGFILE
VALIDATE $? " editing remote access to redis"

systemctl enable redis &>> $LOGFILE
VALIDATE $? " redis enabiling "

systemctl start redis &>> $LOGFILE
VALIDATE $? " redis starting"
