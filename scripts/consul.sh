#!/bin/bash
cd images/consul
curl -o consul.zip https://releases.hashicorp.com/consul/1.11.2/consul_1.11.2_linux_amd64.zip
unzip consul.zip
mv consul consul_1.11.2/consul
rm consul.zip
cat <<< $(jq --arg bucket "$bucket" '.CloudConfig.BucketName = $bucket' config.json) > config.json
ops pkg add consul_1.11.2 --name consul_1.11.2
ops image create --package consul_1.11.2 -l -i consul -c config.json --show-debug -t aws -n
