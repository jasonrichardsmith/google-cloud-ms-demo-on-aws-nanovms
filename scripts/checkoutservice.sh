#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' images/checkoutservice/config.json \
	> microservices-demo/src/checkoutservice/config.json
cp -rf images/checkoutservice/etc microservices-demo/src/checkoutservice/
cd microservices-demo/src/checkoutservice
ops image create checkoutservice -i checkoutservice -c config.json --show-debug -t aws
