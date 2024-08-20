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

dnf install maven -y
VALIDATE $? "installing maven"

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

curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? " downloading shipping application"

cd /app 
unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? " unzipping shipping"

mvn clean package
VALIDATE

mv target/shipping-1.0.jar shipping.jar
VALIDATE

cp /home/centos/roboshopo-shell1/shipping.service /etc/systemd/system/shipping.service
VALIDATE

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " shipping demon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? " shipping enabiling "

systemctl start user &>> $LOGFILE
VALIDATE $? " shipping started"

dnf install mysql -y
VALIDATE $? " mysql installed"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql 
VALIDATE

systemctl restart shipping
VALIDATE $? " shipping restarted"

