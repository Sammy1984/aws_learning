#!/bin/bash

aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters Name=tag:Type,Values=cec \
	--query "Reservations[].Instances[].InstanceId[]" --output text)
