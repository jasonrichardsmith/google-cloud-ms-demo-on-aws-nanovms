#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' images/currencyservice/config.json \
	> microservices-demo/src/currencyservice/config.json
cp -rf images/currencyservice/etc microservices-demo/src/currencyservice/
cd microservices-demo/src/currencyservice
ops image create --package node_v14.2.0 -i currencyservice -c config.json --show-debug -t aws
