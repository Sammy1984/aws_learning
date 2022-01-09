#/!bin/bash

# aws ec2 describe-vpcs --region us-west-2 

for reg in $(cat region.conf)
do
	echo "<-----------------------------------"$reg"------------------------------------------->"
	vpc=$(aws ec2 describe-vpcs --region $reg --filter "Name=is-default,Values=true" --query "Vpcs[].VpcId" --output text)
	
	if [ -z "$vpc" ]
	then
		vpc=$(aws ec2 create-default-vpc --region $reg | grep VpcId | awk -F ':' '{print $2}' | awk -F '"' '{print $2}')
		echo "<----------CREATE VPC---------->"
		
	fi
        echo $vpc
	for zone in $(aws ec2 describe-availability-zones --region $reg \
		--filters "Name=opt-in-status, Values=opt-in-not-required" \
		--query "AvailabilityZones[].{Name:ZoneName}" --output text)
	do
		echo '----------------'
		echo $zone
		echo '----------------'
		s_net=$(aws ec2 describe-subnets --region $reg --filters "Name=availability-zone,Values=$zone" \
			"Name=default-for-az,Values=true" --query "Subnets[].SubnetId" --output text )

		if [ -z "$s_net" ]
		then
			s_net=$(aws ec2 create-default-subnet --region $reg --availability-zone $zone | \
			       	grep SubnetId | awk -F ':' '{print $2}' | awk -F '"' '{print $2}')
			echo "<-----------CREATE SubNet------------>"
		fi
		
		echo $s_net
	done
	echo ''

	sec_gr80=$(aws ec2 describe-security-groups --region $reg --filters "Name=vpc-id,Values=$vpc" \
		--query "SecurityGroups[].GroupName" | grep public-ssh-and-http)
	echo $sec_gr80
	
	sec_gr81=$(aws ec2 describe-security-groups --region $reg --filters "Name=vpc-id,Values=$vpc" \
		--query "SecurityGroups[].GroupName" | grep public-ssh-http-81)
	
	echo $sec_gr81
	
	if [ -z "$sec_gr80" ]

	then
		echo "<-------------------CREATE SECYRITY GROUP: public-ssh-and-http--------------------------->"
		gr_id_80=$(aws ec2 create-security-group --region $reg --group-name "public-ssh-and-http" \
			--description "Allow SSH and HTTP access from the World" \
	       		--vpc-id $vpc | grep GroupId | awk -F ':' '{print $2}' | awk -F '"' '{print $2}')
	

 		aws ec2 authorize-security-group-ingress --region $reg --group-id $gr_id_80 --protocol tcp --port 22 --cidr 0.0.0.0/0

		aws ec2 authorize-security-group-ingress --region $reg --group-id $gr_id_80 --protocol tcp --port 80 --cidr 0.0.0.0/0

	 	#aws ec2 authorize-security-group-egress --region $reg --group-id $gr_id_80 --protocol -1 --port -1 --cidr 0.0.0.0/0


	fi

	
	if [ -z "$sec_gr81" ]

	then
		echo "<-------------------CREATE SECYRITY GROUP: public-ssh-http-81--------------------------->"
		gr_id_81=$(aws ec2 create-security-group --region $reg --group-name "public-ssh-http-81" \
			--description "Allow SSH, HTTP and 81/TCP access from the World" \
	       		--vpc-id $vpc | grep GroupId | awk -F ':' '{print $2}' | awk -F '"' '{print $2}')
	

 		aws ec2 authorize-security-group-ingress --region $reg --group-id $gr_id_81 --protocol tcp --port 22 --cidr 0.0.0.0/0

		aws ec2 authorize-security-group-ingress --region $reg --group-id $gr_id_81 --protocol tcp --port 80 --cidr 0.0.0.0/0
		
		aws ec2 authorize-security-group-ingress --region $reg --group-id $gr_id_81 --protocol tcp --port 81 --cidr 0.0.0.0/0

	 	#aws ec2 authorize-security-group-egress --region $reg --group-id $gr_id_81 --protocol -1 --port -1 --cidr 0.0.0.0/0
	fi
	
	key_rsa=$(aws ec2 describe-key-pairs --region $reg --filters "Name=key-names,Values=student-rsa" --query "KeyPairs[].KeyName" --output text)
	echo $key_rsa	
	key_ed25519=$(aws ec2 describe-key-pairs --region $reg --filters "Name=key-names,Values=student-ed25519" --query "KeyPairs[].KeyName" --output text)
	echo $key_ed25519

	if [ -z "$key_rsa" ]
	then
	echo "<--------------------------------CREATE KEY PAIR---------------------------------------->"
		aws ec2 import-key-pair --region $reg --key-name "student-rsa" --public-key-material fileb://~/.ssh/id_student_rsa.pub
	fi
	if [ -z "$key_ed25519" ]
	then
	echo "<--------------------------------CREATE KEY PAIR---------------------------------------->"
		aws ec2 import-key-pair --region $reg --key-name "student-ed25519" --public-key-material fileb://~/.ssh/id_student_ed25519.pub
	fi
	echo ''
	echo ''
done	

