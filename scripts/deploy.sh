#!/bin/bash
set -e
docker build -t deploybuild -f deploy/Dockerfile .
docker run -e AWS_DEFAULT_REGION -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID deploybuild
