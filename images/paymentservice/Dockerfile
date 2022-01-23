FROM bitnami/git:latest as git
WORKDIR working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git


FROM node:16-alpine as build
WORKDIR /working
COPY --from=git /working /working
RUN apk add --no-cache python3 make g++
RUN cd microservices-demo/src/paymentservice && \
	npm install --only=production

FROM jasonrichardsmith/ops:0.1.28.3 as image
WORKDIR working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/paymentservice.sh
