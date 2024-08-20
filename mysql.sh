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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? " disabiling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo
VALIDATE $? "copying my sql repo"

dnf install mysql-community-server -y
VALIDATE $? "installing mysql server"

systemctl enable mysqld
VALIDATE $? "enabiling mysql server"

systemctl start mysqld
VALIDATE $? "starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting root password"

#mysql -uroot -pRoboShop@1
#VALIDATE $? "installing mysql server"
