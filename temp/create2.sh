#!/bin/bash

declare -A al2
declare -A ubuntu
list_os[0]="al2"
list_os[1]="ubuntu"

#Amazon Linux 2 - os1
al2[ami]="$(aws ssm get-parameters --name /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
	    --region eu-central-1 --query 'Parameters[0].[Value]' --output text)"
al2[name]="al-ud6"

#Ubuntu 20.04 - os2

ubuntu[ami]="$(aws ssm get-parameters --names \
	              /aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id \
		          --query 'Parameters[0].[Value]' --output text)"

ubuntu[name]="ubuntu-ud6"


while [ -n "$1" ]
do
	case "$1" in
		--region) region="$2"
		       	if grep "$region" region.conf
			then




for i in ${list_os[@]}; do
    name=${i}"[name]"
    ami=${i}"[ami]"
aws ec2 run-instances \
    	    --region $region --image-id ${!ami} --instance-type t2.micro \
	    --region eu-central-1 --key-name student-ed25519 \
	    --security-group-ids sg-062bd2cab33d54f92 --subnet-id subnet-6e65f422 \
	    --tag-specifications ResourceType=instance,Tags=\[\{Key=Name,Value=${!name}\},\{Key=Type,Value=cec\}\] \
	    --iam-instance-profile Name=CloudEngJ2Ch06Profile --user-data file://user_data.sh
done




