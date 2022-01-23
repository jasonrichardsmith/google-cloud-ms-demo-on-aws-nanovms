FROM bitnami/git:latest as git
WORKDIR working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git

FROM openjdk:8-slim as build
WORKDIR working
COPY --from=git /working/ /working/
RUN cd microservices-demo/src/adservice && \
	chmod +x gradlew && \
	./gradlew downloadRepos && \
	./gradlew installDist

FROM jasonrichardsmith/ops:0.1.28.3 as image
WORKDIR working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/adservice.sh
