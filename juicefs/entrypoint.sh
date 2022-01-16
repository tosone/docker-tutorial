#!/bin/sh
set -ex

juicefs format --storage qiniu --bucket ${BUCKET} --access-key ${AK} --secret-key ${SK} sqlite3://juicefs.db juicefs

exec "$@"
