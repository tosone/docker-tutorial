#!/bin/sh

set -e

sed -i "s#\"SERVER_ADDR\"#\"${SERVER_ADDR:-china.tosone.cn}\"#g" frpc.toml
sed -i "s#\"SERVER_PORT\"#${SERVER_PORT:-9000}#g" frpc.toml
sed -i "s#\"LOCAL_PORT\"#${LOCAL_PORT:-22}#g" frpc.toml
sed -i "s#\"REMOTE_PORT\"#${REMOTE_PORT:-9001}#g" frpc.toml
sed -i "s#\"CLIENT_NAME\"#\"${CLIENT_NAME:-ssh}\"#g" frpc.toml

exec "$@"
