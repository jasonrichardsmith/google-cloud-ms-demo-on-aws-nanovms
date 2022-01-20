#!/bin/bash
cd microservices-demo/src/emailservice
patch logger.py logger.patch
python3 -m venv .venv --prompt nanovm
source .venv/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt
deactivate
curl https://ops.city/get.sh -sSfL | sh
/root/.ops/bin/ops image create --package python_3.8.6 -i emailservice -c config.json --show-debug -t aws
