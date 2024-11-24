#!/bin/sh

set -e

sed -i "s#\"BIND_PORT\"#${BIND_PORT:-9000}#g" frps.toml

exec "$@"
