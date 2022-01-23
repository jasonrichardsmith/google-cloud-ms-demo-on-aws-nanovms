#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' images/adservice/config.json\
	> microservices-demo/src/adservice/config.json
cp -rf images/adservice/etc microservices-demo/src/adservice/
cd microservices-demo/src/adservice
ops image create --package java_1.8.0_191 -i adservice -c config.json --show-debug -t aws
