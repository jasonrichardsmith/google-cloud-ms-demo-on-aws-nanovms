#!/bin/bash
aws ec2 describe-images --owners self --filters "Name=tag:CreatedBy,Values=ops" \
	--query 'Images[*].[ImageId,Tags[?Key==`Name`].Value | [0]]' --output text \
	| while read ami name; do
	name="${name^^}AMI"
	echo "export $name='$ami'"
done
