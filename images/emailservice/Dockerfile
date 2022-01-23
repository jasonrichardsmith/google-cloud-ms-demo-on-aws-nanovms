FROM bitnami/git:latest as git
WORKDIR working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git


FROM python:3.7-slim as build
WORKDIR /working
COPY --from=git /working /working
RUN apt-get update -qqy && apt-get -qqy install wget g++ patch
RUN ./scripts/emailservicepythonbuild.sh

FROM jasonrichardsmith/ops:0.1.28.3 as image
WORKDIR working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/emailservice.sh
