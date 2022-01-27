FROM bitnami/git:latest as git
WORKDIR working
COPY . .
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
RUN cd microservices-demo && git checkout af0515f7c94044cec0ff7faab5e7c32bf09ab7bf


FROM golang:1.17.5-alpine as build
WORKDIR /working
COPY --from=git /working /working
RUN apk add --no-cache ca-certificates
RUN apk add build-base
RUN cd microservices-demo/src/frontend && \
	go mod download && \
	go build -ldflags "-linkmode external -extldflags -static" -a .

FROM jasonrichardsmith/ops:0.1.28.3 as image
WORKDIR working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/frontend.sh
