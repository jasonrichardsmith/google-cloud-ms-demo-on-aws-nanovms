FROM alpine:3.15.0
RUN apk add curl jq bash
RUN curl https://ops.city/get.sh -sSfL | sh
RUN ln -sf ~/.ops/bin/ops /usr/bin/ops
