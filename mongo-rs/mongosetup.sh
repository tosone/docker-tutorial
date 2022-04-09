#!/bin/bash

MONGODB1=mongo1
MONGODB2=mongo2
MONGODB3=mongo3

DOMAIN=mongo${HOST_DOMAIN}

echo "Waiting for startup..."
sleep 30

echo SETUP.sh time now: `date +"%T" `
mongo --host ${DOMAIN}:30001 -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} <<EOF
var cfg = {
  "_id": "rs0",
  "protocolVersion": 1,
  "version": 1,
  "members": [
    {
      "_id": 0,
      "host": "${DOMAIN}:30001",
      "priority": 2
    },
    {
      "_id": 1,
      "host": "${DOMAIN}:30002",
      "priority": 0
    },
    {
      "_id": 2,
      "host": "${DOMAIN}:30003",
      "priority": 0,
    }
  ]
};
rs.initiate(cfg, { force: true });
rs.secondaryOk();
db.getMongo().setReadPref("primary");
rs.status();
EOF
