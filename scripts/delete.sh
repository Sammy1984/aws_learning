#!/bin/bash

for region in $(cat region.conf)
do
	aws ec2 terminate-instances --region $region --instance-ids $(aws ec2 describe-instances --region $region \
		--filters Name=tag:Type,Values=cec \
		--query "Reservations[].Instances[].InstanceId[]" --output text)
done
