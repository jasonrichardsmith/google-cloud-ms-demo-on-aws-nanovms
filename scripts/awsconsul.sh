#!/bin/bash
cd images/awsconsul
cat <<< $( jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' config.json) > config.json
ops image create awsconsul -i awsconsul -c config.json --show-debug -t aws
