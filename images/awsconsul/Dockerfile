FROM bitnami/git:latest as git
WORKDIR /working
COPY . .
RUN git clone https://codeberg.org/jasonrichardsmith/awsconsul.git

FROM golang:1.17.5-alpine as build
WORKDIR /working
COPY --from=git /working/ /working/
RUN apk add --no-cache ca-certificates
RUN apk add build-base
RUN cd awsconsul && \
	go mod download && \
	go build -ldflags "-linkmode external -extldflags -static" -a . && \
	mv awsconsul ../images/awsconsul/

FROM jasonrichardsmith/ops:0.1.28.3 as image
WORKDIR /working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/awsconsul.sh
