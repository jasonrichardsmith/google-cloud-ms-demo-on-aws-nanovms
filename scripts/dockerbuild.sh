#!/bin/bash
set -e
docker build -t ${1}build -f images/${1}/Dockerfile .
docker run --env bucket=$BUCKET -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID ${1}build
