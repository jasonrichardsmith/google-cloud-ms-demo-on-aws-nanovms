#!/bin/bash
cd images/logagent
cat <<< $(jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' config.json) > config.json
cd microservices-demo/src/logagent
opssafe image create --package node_v14.2.0 -i logagent -c config.json --show-debug -t aws
