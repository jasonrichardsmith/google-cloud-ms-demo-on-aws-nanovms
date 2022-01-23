#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' images/emailservice/config.json \
	> microservices-demo/src/emailservice/config.json
cp -rf images/emailservice/etc microservices-demo/src/emailservice/
cp -rf images/emailservice/usr microservices-demo/src/emailservice/
cd microservices-demo/src/emailservice
ops image create --package python_3.8.6 -i emailservice -c config.json --show-debug -t aws -n
