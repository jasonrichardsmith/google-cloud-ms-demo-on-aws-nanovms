FROM bitnami/git:latest as git
WORKDIR /working
RUN git clone https://github.com/nanovms/ops.git

FROM golang:1.17.5-alpine as build
WORKDIR /working/ops
COPY --from=git /working /working
RUN apk add --no-cache ca-certificates patch
RUN apk add build-base
COPY concurrent.patch .
WORKDIR /working/ops
RUN patch aws/aws_image.go concurrent.patch
RUN go mod download && \
	go build -ldflags "-linkmode external -extldflags -static" -a .


FROM alpine:3.15.0
RUN apk add curl jq bash
RUN curl https://ops.city/get.sh -sSfL | sh
RUN ln -sf ~/.ops/bin/ops /usr/bin/ops
COPY --from=build /working/ops/ops /usr/bin/opssafe
