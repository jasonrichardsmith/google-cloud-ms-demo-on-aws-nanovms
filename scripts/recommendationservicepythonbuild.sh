#!/bin/bash
cp images/recommendationservice/logger.patch microservices-demo/src/recommendationservice/
cd microservices-demo/src/recommendationservice
patch logger.py logger.patch
python3 -m venv .venv --prompt nanovm
source .venv/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt
deactivate
