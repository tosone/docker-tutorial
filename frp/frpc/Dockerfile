FROM alpine:3.20

LABEL maintainer="Tosone <i@tosone.cn>"

ARG TARGETARCH
ARG FRP_VERSION=0.61.0

RUN sed -i 's/https:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g' /etc/apk/repositories && \
  apk add --no-cache pcre bash ca-certificates && \
  apk add --no-cache --virtual TMP wget tar && \
  wget --progress=dot:giga https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz && \
  tar zxvf frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz && \
  mv frp_${FRP_VERSION}_linux_${TARGETARCH}/frpc /usr/bin && \
  apk del TMP && \
  rm -rf frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz frp_${FRP_VERSION}_linux_${TARGETARCH}

WORKDIR /app

COPY frpc.toml .
COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]

CMD ["frpc", "-c", "frpc.toml"]

# docker buildx build -t tosone/docker-tutorial:frpc --push --platform linux/amd64,linux/arm64 .

# docker run -d --name frpc --hostname frpc --restart always --network host --env SERVER_ADDR=18.141.164.177 --env REMOTE_PORT=9001 --env CLIENT_NAME=radxa-large tosone/docker-tutorial:frpc
# docker run -d --name frpc --hostname frpc --restart always --network host --env SERVER_ADDR=18.141.164.177 --env REMOTE_PORT=9002 --env CLIENT_NAME=radxa-small tosone/docker-tutorial:frpc
