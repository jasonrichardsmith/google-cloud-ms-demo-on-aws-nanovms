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
	xmlstarlet edit -L --append "//Project/PropertyGroup/TargetFramework" \
		--type elem --name "InvariantGlobalization" --value "true" cartservice.csproj && \
	dotnet restore cartservice.csproj -r linux-x64 && \
	dotnet publish -c release --self-contained --runtime linux-x64 \
		-o /publish -p:PublishSingleFile=true
RUN curl https://ops.city/get.sh -sSfL | sh
RUN ln -sf ~/.ops/bin/ops /usr/bin/ops
WORKDIR /working
ENTRYPOINT ./scripts/cartservice.sh
