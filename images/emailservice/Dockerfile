FROM bitnami/git:latest as git
WORKDIR /working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
RUN cd microservices-demo && git checkout 2e796c9dbb439f3fef16d748eb321723d4f6d035


FROM python:3.8-slim as build
WORKDIR /working
COPY --from=git /working/ /working/
RUN apt-get update -qqy && apt-get -qqy install wget g++ patch
RUN ./scripts/emailservicepythonbuild.sh

FROM jasonrichardsmith/ops:0.1.28.4 as image
WORKDIR /working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/emailservice.sh
