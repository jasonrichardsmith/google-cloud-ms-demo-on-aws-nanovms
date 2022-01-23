#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' images/paymentservice/config.json \
	> microservices-demo/src/paymentservice/config.json
cp -rf images/paymentservice/etc microservices-demo/src/paymentservice/
cd microservices-demo/src/paymentservice
ops image create --package node_v14.2.0 -i paymentservice -c config.json --show-debug -t aws
