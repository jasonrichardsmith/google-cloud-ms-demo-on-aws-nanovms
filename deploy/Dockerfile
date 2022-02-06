FROM cloudreach/sceptre:2.7.1
WORKDIR /working/
COPY config config
COPY templates templates
COPY images images
COPY scripts/amiexports.sh .
RUN pip install awscli
ENTRYPOINT eval $(./amiexports.sh) && \
	sceptre launch -y test/network && \
	sceptre launch -y test/consul && \
	sceptre launch -y test/logger && \
	sceptre launch -y test/services
