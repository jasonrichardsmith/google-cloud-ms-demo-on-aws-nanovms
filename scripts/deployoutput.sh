#!/bin/bash
set -e

eval $(docker run -v $(pwd):/project -e AWS_DEFAULT_REGION -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID cloudreach/sceptre:2.7.1 list outputs --export=envvar test/consul/alb.yaml | grep ConsulDNS)

echo -e "\nVisit Consul here http://$SCEPTRE_ConsulDNS:8500\n"

eval $(docker run -v $(pwd):/project -e AWS_DEFAULT_REGION -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID cloudreach/sceptre:2.7.1 list outputs --export=envvar test/services/frontend/asg.yaml  | grep ServiceDNS)


echo -e "\nVisit your webshop here http://$SCEPTRE_ServiceDNS:8080\n"
