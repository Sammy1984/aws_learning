#!/bin/bash

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip"

if grep -iq "amzn" /etc/os-release; then
	yum install unzip -y
	unzip awscliv2.zip
	./aws/install
	aws configure set default.region eu-central-1
	bucket_name="cec-"$(aws sts get-caller-identity --query Account --output text)"-j2"
	aws s3 cp s3://$bucket_name/user-data/al2_setting_instance.sh ./
	aws s3 cp s3://$bucket_name/user-data/assume_role.sh /usr/local/bin/assume_role.sh	
	aws s3 cp s3://$bucket_name/user-data/assume_role.service /lib/systemd/system/assume_role.service
	chmod +x /usr/local/bin/assume_role.sh
 	chmod 644 /lib/systemd/system/assume_role.service
	chmod +x ./al2_setting_instance.sh
	./al2_setting_instance.sh
else 
	apt-get install unzip -y
	unzip awscliv2.zip
	./aws/install
	aws configure set default.region eu-central-1
	bucket_name="cec-"$(aws sts get-caller-identity --query Account --output text)"-j2"
	aws s3 cp s3://$bucket_name/user-data/assume_role.sh /usr/local/bin/
	chmod +x ./assume_role.sh
	aws s3 cp s3://$bucket_name/user-data/setting_instance.sh ./
	aws s3 cp s3://$bucket_name/user-data/assume_role.sh /usr/local/bin/assume_role.sh	
	aws s3 cp s3://$bucket_name/user-data/assume_role.service /lib/systemd/system/assume_role.service
	chmod +x ./setting_instance.sh
	chmod +x /usr/local/bin/assume_role.sh
 	chmod 644 /lib/systemd/system/assume_role.service
	./setting_instance.sh
fi
