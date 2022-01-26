#!/bin/bash
set -e

docker run -v $(pwd):/project -e AWS_DEFAULT_REGION -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID cloudreach/sceptre:2.7.1 destroy -y test
