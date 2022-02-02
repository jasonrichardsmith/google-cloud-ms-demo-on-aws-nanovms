#!/bin/bash
jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' \
                             images/cartservice/config.json \
                             > microservices-demo/src/cartservice/src/config.json
cp -rf images/adservice/etc microservices-demo/src/cartservice/src/
cd microservices-demo/src/cartservice/src/
opssafe image create /publish/cartservice -i cartservice -c config.json --show-debug -t aws -n
