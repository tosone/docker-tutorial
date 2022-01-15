#!/bin/sh

cat << EOF
stream {
	upstream group {
EOF

for i in `echo ${SHADOWSOCKS_SERVER} | sed 's/"//g'`; do
cat << EOF
		server $i:${SHADOWSOCKS_PORT};
EOF
done

cat << EOF
	}
	server {
		listen ${SHADOWSOCKS_PORT};
		listen ${SHADOWSOCKS_PORT} udp;
		proxy_pass group;
	}
}
EOF
