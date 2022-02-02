#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' images/recommendationservice/config.json \
	> microservices-demo/src/recommendationservice/config.json
cp -rf images/recommendationservice/etc microservices-demo/src/recommendationservice/
cp -rf images/recommendationservice/usr microservices-demo/src/recommendationservice/
cd microservices-demo/src/recommendationservice
rm -rf ./.venv/bin
opssafe image create --package python_3.8.6 -i recommendationservice -c config.json --show-debug -t aws -n
