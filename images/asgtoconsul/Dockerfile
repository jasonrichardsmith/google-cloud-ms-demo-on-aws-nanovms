FROM golang:1.17.5-alpine as build
WORKDIR /working
COPY . .
RUN apk add --no-cache ca-certificates
RUN apk add build-base
RUN cd images/asgtoconsul && \
	go mod download && \
	go build -ldflags "-linkmode external -extldflags -static" -a .
RUN ls -al images/asgtoconsul

FROM jasonrichardsmith/ops:0.1.28.3 as image
WORKDIR /working
COPY --from=build /working/ /working/
ENTRYPOINT ./scripts/asgtoconsul.sh
