#!/bin/bash

aws ec2 describe-regions --filters "Name=opt-in-status,Values=opt-in-not-required" --query "Regions[].{Name:RegionName}" --output text > ~/dev_ops/conf/regions-allowed.conf
