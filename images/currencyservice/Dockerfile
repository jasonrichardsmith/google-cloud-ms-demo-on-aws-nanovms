FROM bitnami/git:latest as git
WORKDIR working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
RUN cd microservices-demo && git checkout 0d5c2f3bd2143abc68c9300841b7affae34d7a12


FROM node:16-alpine as build
WORKDIR /working
COPY --from=git /working /working
RUN apk add --no-cache python3 make g++
RUN cd microservices-demo/src/currencyservice && \
	npm install --only=production

FROM jasonrichardsmith/ops:0.1.28.3 as image
WORKDIR working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/currencyservice.sh
