FROM bitnami/git:latest as git
WORKDIR /working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
RUN cd microservices-demo && git checkout af0515f7c94044cec0ff7faab5e7c32bf09ab7bf


FROM python:3.8-slim as build
WORKDIR /working
COPY --from=git /working/ /working/
RUN apt-get update -qqy && apt-get -qqy install wget g++ patch
RUN ./scripts/recommendationservicepythonbuild.sh

FROM jasonrichardsmith/ops:0.1.28.4 as image
WORKDIR /working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/recommendationservice.sh
