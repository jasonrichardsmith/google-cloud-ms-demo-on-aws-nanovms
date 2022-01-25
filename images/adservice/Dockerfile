FROM bitnami/git:latest as git
WORKDIR /working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git

FROM ubuntu:20.04 as build
RUN apt-get update
RUN apt-get install -y jq curl qemu bash default-jdk wget
WORKDIR /working
COPY --from=git /working/ /working/
WORKDIR /working/microservices-demo/src/adservice
RUN chmod +x gradlew
RUN ./gradlew downloadRepos
RUN ./gradlew installDist
RUN mkdir -p /opt/cprof && \
    wget -q -O- https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz \
    | tar xzv -C /opt/cprof && \
    rm -rf profiler_java_agent.tar.gz

FROM jasonrichardsmith/ops:0.1.28.4 as image
WORKDIR /working
COPY --from=build /working/ /working/
COPY --from=build /opt/cprof/ /opt/cprof/
ENTRYPOINT ./scripts/adservice.sh
