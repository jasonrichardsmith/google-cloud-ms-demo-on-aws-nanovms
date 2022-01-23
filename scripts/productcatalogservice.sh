#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' \
	images/productcatalogservice/config.json \
	> microservices-demo/src/productcatalogservice/config.json
cp -rf images/productcatalogservice/etc microservices-demo/src/productcatalogservice/
cd microservices-demo/src/productcatalogservice
ops image create productcatalogservice -i productcatalogservice -c config.json --show-debug -t aws
