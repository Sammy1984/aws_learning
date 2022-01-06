#!/bin/bash

ACC_ID="$(aws sts get-caller-identity --query Account --output text)"

sed '/AWS_ACCESS_KEY_ID/d' ~/.bashrc
sed '/AWS_SECRET_ACCESS_KEY/d' ~/.bashrc
sed '/AWS_SESSION_TOKEN=/d' ~/.bashrc

aws sts assume-role --role-arn "arn:aws:iam::272304640086:role/CloudEngJ2Ch06UpdateDNSZone603383945425" --role-session-name "Fail" > assume.tmp

echo "export AWS_ACCESS_KEY_ID="$(grep  AccessKeyId assume.tmp | awk -F ':' '{print $2}' | awk -F '"' '{print$2}')>>~/.bashrc
echo "export AWS_SECRET_ACCESS_KEY="$(grep  SecretAccessKey assume.tmp | awk -F ':' '{print $2}' | awk -F '"' '{print$2}')>>~/.bashrc
echo "export AWS_SESSION_TOKEN="$(grep  SessionToken assume.tmp | awk -F ':' '{print $2}' | awk -F '"' '{print$2}')>>~/.bashrc


source ~/.bashrc

ZONE="$(aws route53 list-hosted-zones-by-name --dns-name ${ACC_ID}.cirruscloud.click --query 'HostedZones[*].Id')"

ZONE1= $($ZONE  | awk -F '/' '{print $3}' | awk -F '"' '{print$1}')

echo $ZONE1


