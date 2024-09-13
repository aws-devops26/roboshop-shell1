#!/bin/bash
AMI=ami-0b4f379183e5706b9
SG_ID=sg-0541e7f1344e449e2
INSTANCES=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" 
"shipping" "payment" "dispatch" "web")
for i in "${INSTANCES[@]}"
do
    echo "instances: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
     INSTANCE_TYPE="t3.small"
     else
     INSTANCE_TYPE="t2.micro"
    fi
     aws ec2 run-instances --image-id ami-0b4f379183e5706b9
      --instance-type t2.micro  --security-group-ids sg-0541e7f1344e449e2 
      --tag-specifications "ResourceType=instance,Tags=[{key=name,value=production}]"
done