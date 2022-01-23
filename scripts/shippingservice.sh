#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' images/shippingservice/config.json \
	> microservices-demo/src/shippingservice/config.json
cp -rf images/shippingservice/etc microservices-demo/src/shippingservice/
cd microservices-demo/src/shippingservice
ops image create shippingservice -i shippingservice -c config.json --show-debug -t aws
