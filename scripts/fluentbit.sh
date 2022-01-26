#!/bin/bash
cd images/fluentbit
cat <<< $(jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' config.json) > config.json
ops pkg add aws-for-fluent-bit-2.21.6 --name aws-for-fluent-bit-2.21.6
ops image create --package aws-for-fluent-bit-2.21.6 -l -i fluentbit -c config.json --show-debug -t aws
