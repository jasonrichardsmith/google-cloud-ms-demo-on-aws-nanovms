#!/bin/bash
cd images/logger
cat <<< $( jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' config.json) > config.json
/root/.ops/bin/ops image create logger -i logger -c config.json --show-debug -t aws
