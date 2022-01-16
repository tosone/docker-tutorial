FROM debian:bullseye as base

RUN sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list && \
  sed -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list && \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  ca-certificates curl wget tar && \
  export JFS_LATEST_TAG=$(curl -s https://api.github.com/repos/juicedata/juicefs/releases/latest | grep 'tag_name' | cut -d '"' -f 4 | tr -d 'v') && \
  wget "https://github.com/juicedata/juicefs/releases/download/v${JFS_LATEST_TAG}/juicefs-${JFS_LATEST_TAG}-linux-amd64.tar.gz" && \
  tar zxvf juicefs-${JFS_LATEST_TAG}-linux-amd64.tar.gz && \
  rm -rf /var/lib/apt/lists/*

FROM debian:bullseye

RUN sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list && \
  sed -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list && \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  ca-certificates fuse librados2 && \
  rm -rf /var/lib/apt/lists/*

COPY --from=base /juicefs /usr/bin

ENV BUCKET=
ENV AK=
ENV SK=

VOLUME /juicedata
VOLUME /juicefs.db

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["juicefs", "mount", "--cache-dir", "/juicedata/cache-dir", "--cache-size", "1024", "sqlite3://juicefs.db", "/juicedata/data-dir"]
