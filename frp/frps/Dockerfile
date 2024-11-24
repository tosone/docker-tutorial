FROM alpine:3.20

LABEL maintainer="Tosone <i@tosone.cn>"

ARG TARGETARCH
ARG FRP_VERSION=0.61.0

RUN sed -i 's/https:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g' /etc/apk/repositories && \
  apk add --no-cache pcre bash ca-certificates && \
  apk add --no-cache --virtual TMP wget tar && \
  wget --progress=dot:giga https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz && \
  tar zxvf frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz && \
  mv frp_${FRP_VERSION}_linux_${TARGETARCH}/frps /usr/bin && \
  apk del TMP && \
  rm -rf frp_${FRP_VERSION}_linux_${TARGETARCH}.tar.gz frp_${FRP_VERSION}_linux_${TARGETARCH}

WORKDIR /app

COPY frps.toml .
COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]

CMD ["frps", "-c", "frps.toml"]

# docker buildx build -t tosone/docker-tutorial:frps --push --platform linux/amd64,linux/arm64 .

# docker run -d --name frps --hostname frps --restart always -p 9000:9000 -p 9001:9001 -p 9002:9002 tosone/docker-tutorial:frps
