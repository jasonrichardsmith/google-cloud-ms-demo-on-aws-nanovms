#!/bin/bash
aws ec2 describe-images --owners self --filters "Name=tag:CreatedBy,Values=ops" \
	--query 'Images[*].[ImageId]' --output text \
	| while read ami; do
	echo $ami
	aws ec2 deregister-image --image-id $ami
done
