#!/bin/bash
set -e
docker build --no-cache -t ${1}build -f images/${1}/Dockerfile .
docker run --rm --env bucket=$BUCKET -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID ${1}build
docker image rm ${1}build
