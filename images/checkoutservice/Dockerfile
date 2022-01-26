FROM bitnami/git:latest as git
WORKDIR working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
RUN cd microservices-demo && git checkout 0d5c2f3bd2143abc68c9300841b7affae34d7a12


FROM golang:1.17.5-alpine as build
WORKDIR /working
COPY --from=git /working /working
RUN apk add --no-cache ca-certificates
RUN apk add build-base
RUN cd microservices-demo/src/checkoutservice && \
	go mod download && \
	go build -ldflags "-linkmode external -extldflags -static" -a .

FROM jasonrichardsmith/ops:0.1.28.3 as image
WORKDIR working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/checkoutservice.sh
