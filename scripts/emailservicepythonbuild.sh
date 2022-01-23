#!/bin/bash
cp images/emailservice/logger.patch microservices-demo/src/emailservice/
cd microservices-demo/src/emailservice
patch logger.py logger.patch
python3 -m venv .venv --prompt nanovm
source .venv/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt
deactivate
