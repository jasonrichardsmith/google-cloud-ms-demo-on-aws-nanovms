FROM bitnami/git:latest as git
WORKDIR /working
RUN git clone https://github.com/nanovms/ops.git

FROM golang:1.17.5-alpine as opspatched
WORKDIR /working/ops
COPY --from=git /working /working
RUN apk add --no-cache ca-certificates patch
RUN apk add build-base
COPY concurrent.patch .
WORKDIR /working/ops
RUN patch aws/aws_image.go concurrent.patch
RUN go mod download && \
	go build -ldflags "-linkmode external -extldflags -static" -a .


FROM ubuntu:20.04 as build
WORKDIR /working
COPY . .
ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update
RUN apt-get install -y wget git curl apt-transport-https jq xmlstarlet
RUN wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y dotnet-sdk-6.0
RUN rm packages-microsoft-prod.deb
RUN git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
RUN cd microservices-demo/src/cartservice/src/ && \
	git checkout 0d5c2f3bd2143abc68c9300841b7affae34d7a12 && \
	xmlstarlet edit -L --append "//Project/PropertyGroup/TargetFramework" \
		--type elem --name "InvariantGlobalization" --value "true" cartservice.csproj && \
	dotnet restore cartservice.csproj -r linux-x64 && \
	dotnet publish -c release --self-contained --runtime linux-x64 \
		-o /publish -p:PublishSingleFile=true

COPY --from=opspatched /working/ops/ops /usr/bin/opssafe
WORKDIR /working
ENTRYPOINT ./scripts/cartservice.sh
