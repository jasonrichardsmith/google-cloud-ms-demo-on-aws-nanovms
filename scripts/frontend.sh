#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' images/frontend/config.json \
	> microservices-demo/src/frontend/config.json
cp -rf images/frontend/etc microservices-demo/src/frontend/
cd microservices-demo/src/frontend
ops image create frontend -i frontend -c config.json --show-debug -t aws
