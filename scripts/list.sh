#!/bin/bash

aws ec2 describe-instances \
		--filters Name=tag:Type,Values=cec Name=instance-state-name,Values=running \
	       	--query "Reservations[].Instances[].{"Instance_ID":InstanceId, \
		"Instance_Public_IP":PublicIpAddress, \
		"Instance_OS_Name":Tags[?Key==\`Name\`].Value | [0]}" --output table



