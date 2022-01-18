#!/bin/bash

while [ -n "$1" ];do
	case "$1" in
		--region) region="$2"
			shift
			if grep -x $region region.conf
			then
				echo "Регион $region присутствует в списке"
			else
				echo "$region не найден"
				break
			fi ;;
		--os) os="$2"
			shift
			case "$os" in
				ubuntu) last_ver='/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id' ;;
				al2) last_ver='/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2' ;;
				*) echo "$os - такой ОС не найдено"
				break ;;
			esac ;;

		*) 
		 echo "Нет такого параметра - $1"
		 break ;;
	esac
	shift
done

ami="$(aws ssm get-parameters --names $last_ver --query 'Parameters[0].[Value]' --output text)"

aws ec2 run-instances \
    	--image-id $ami --instance-type t2.micro \
	    --region eu-central-1 --key-name student-ed25519 \
	    --security-groups public-ssh-http-81 \
	    --tag-specifications ResourceType=instance,Tags=\[\{Key=Name,Value=$os"-ud7"\},\{Key=Type,Value=cec\},\{Key=OSType,Value=$os"-ud7"\}\] \
	    --iam-instance-profile Name=CloudEngJ2Ch06Profile --user-data file://user_data.sh




