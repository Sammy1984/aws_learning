#!/bin/bash

aws sts assume-role --role-arn "arn:aws:iam::272304640086:role/CloudEngJ2Ch06UpdateDNSZone603383945425" --role-session-name "Fail" > /tmp/assume.tmp
<<comments
cat > ~/.bashrc <<EOF

# User specific aliases and functions

#alias rm='rm -i'
#alias cp='cp -i'
#alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi

EOF
comments

export AWS_ACCESS_KEY_ID="$(grep  AccessKeyId /tmp/assume.tmp | awk -F ':' '{print $2}' | awk -F '"' '{print$2}')"
export AWS_SECRET_ACCESS_KEY="$(grep  SecretAccessKey /tmp/assume.tmp | awk -F ':' '{print $2}' | awk -F '"' '{print$2}')"
export AWS_SESSION_TOKEN="$(grep  SessionToken /tmp/assume.tmp | awk -F ':' '{print $2}' | awk -F '"' '{print$2}')"

cp /root/.bashrc /home/ec2-user/.bashrc
chown ec2-user:ec2-user /home/ec2-user/.bashrc

source ~/.bashrc
source /home/ec2-user/.bashrc

ZONE="$(aws route53 list-hosted-zones-by-name --dns-name "603383945425.cirruscloud.click" --query 'HostedZones[*].Id' | grep -o 'Z[A-Z)-9]*')"

INSTANCE_ID="$(curl http://169.254.169.254/latest/meta-data/instance-id)"

IPADDR="$(wget -qO- eth0.me)"

echo $IPADDR

cat > ~/twp.json <<EOF
{
            "Changes": [{
            "Action": "UPSERT",
                        "ResourceRecordSet": {
				    "Name": "$(hostname)",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "$IPADDR"}]
			 }}]
	 }
EOF
cd ~/
aws route53 change-resource-record-sets --hosted-zone-id $ZONE	--change-batch file://twp.json
