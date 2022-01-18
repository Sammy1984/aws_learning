#!/bin/bash


for region in $(cat region.conf)
do
	echo "<=========== $region ==========>"
	aws ec2 describe-instances \
			--region $region --filters Name=tag:Type,Values=cec Name=instance-state-name,Values=running \
	       		--query "Reservations[].Instances[].{"Instance_ID":InstanceId, \
			"Instance_Public_IP":PublicIpAddress, \
			"Instance_OS_Name":Tags[?Key==\`Name\`].Value | [0]}" --output table
done


