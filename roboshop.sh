#!/bin/bash
AMI=ami-0b4f379183e5706b9
SG_ID=sg-0541e7f1344e449e2
INSTANCES=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" 
"shipping" "payment" "dispatch" "web")
ZONE_ID=Z025434420MOIOXIRVMIF
DOMAIN_NAME="awssrivalli.online"
for i in "${INSTANCES[@]}"
do
    echo "instances: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
     INSTANCE_TYPE="t3.small"
     else
     INSTANCE_TYPE="t2.micro"
    fi
    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --instance-type $INSTANCE_TYPE --security-group-ids  sg-0541e7f1344e449e2 --tag-specifications "ResourceType=instance,
    Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"


  #creating r53 record make sure delete exisisting record
  aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Creating a record set for cognito endpoint"
    ,"Changes": [{
      "Action"              : "CREATE"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$i'.'$DOMAIN_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP_ADDRESS'"
        }]
      }
    }]
  } 
    '
done

