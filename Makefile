include .env
export $(shell sed 's/=.*//' .env)

export COMPOSE_IGNORE_ORPHANS=True # ignore others container

PROJECT_NAME=tutorial

all = gitea gogs mongo redis mysql influxdb filebrowser jupyter portainer drone-server drone-runner watchtower clickhouse
others = frps frpc netdata shadowsocks httpbin phpmyadmin

run: ensure-dir traefik frps frpc postgres $(all)

.PHONY: install
install:
	curl -fsSL https://get.docker.com | sh
	sudo usermod -aG docker $(USER)
	echo "docker installed, now you should exit and login again, then run 'make docker-network'"

.PHONY: docker-network
docker-network:
	docker network create $(DOCKER_NETWORK)

.PHONY: ensure-dir
ensure-dir:
	$(foreach dir, $(all), $(shell if [ ! -d $(VOLUME_PREFIX)/$(dir) ]; then mkdir -p $(VOLUME_PREFIX)/$(dir); fi))

.PHONY: $(all) $(others)
$(all) $(others):
	docker compose -p ${PROJECT_NAME} up --force-recreate -d $@

.PHONY: shadowsocks-proxy
shadowsocks-proxy:
	cd $@ && sh gen.sh > modules-enabled/shadowsocks.conf
	docker compose -p ${PROJECT_NAME} up --force-recreate -d --build $@
	$(RM) $@/modules-enabled/shadowsocks.conf

.PHONY: postgres
postgres: ensure-dir
	cd $@ && sh gen.sh
	if [ ! -d $(VOLUME_PREFIX)/$@ ]; then mkdir -p $(VOLUME_PREFIX)/$@; fi
	if [ ! -d $(VOLUME_PREFIX)/$@/data ]; then mkdir -p $(VOLUME_PREFIX)/$@/data; fi
	if [ ! -d ${VOLUME_PREFIX}/$@/key ]; then mkdir -p ${VOLUME_PREFIX}/$@/key; fi
	sudo cp -r $@/* ${VOLUME_PREFIX}/$@/key
	cd ${VOLUME_PREFIX}/$@/key && sudo chmod 600 server.key && sudo chown 70:70 server.key
	docker compose -p ${PROJECT_NAME} up --force-recreate -d $@

.PHONY: traefik
traefik:
	if [ ! -d $(VOLUME_PREFIX)/$@ ]; then mkdir -p $(VOLUME_PREFIX)/$@; fi
	if [ ! -f $(VOLUME_PREFIX)/$@/acme.json ]; then touch $(VOLUME_PREFIX)/$@/acme.json; fi
	sudo chmod 600 $(VOLUME_PREFIX)/$@/acme.json
	docker compose -p ${PROJECT_NAME} up --force-recreate -d $@

.PHONY: etcd
etcd:
	if [ ! -d $(VOLUME_PREFIX)/$@/$@1 ]; then mkdir -p $(VOLUME_PREFIX)/$@/$@1; fi
	if [ ! -d $(VOLUME_PREFIX)/$@/$@2 ]; then mkdir -p $(VOLUME_PREFIX)/$@/$@2; fi
	if [ ! -d $(VOLUME_PREFIX)/$@/$@3 ]; then mkdir -p $(VOLUME_PREFIX)/$@/$@3; fi
	cd $@ && docker compose -p ${PROJECT_NAME} up --force-recreate -d etcd-1 etcd-2 etcd-3

.PHONY: elastic
elastic:
	if [ ! -d $(VOLUME_PREFIX)/$@ ]; then mkdir -p $(VOLUME_PREFIX)/$@; fi
	cd $@ && docker compose -p ${PROJECT_NAME} up --force-recreate -d elasticsearch kibana

.PHONY: registry
registry:
	if [ ! -d $(VOLUME_PREFIX)/$@ ]; then mkdir -p $(VOLUME_PREFIX)/$@; fi
	docker run --entrypoint htpasswd httpd:2 -Bbn $(USERNAME) $(SECRETPERSONAL) > registry/auth/htpasswd
	docker compose -p ${PROJECT_NAME} up --force-recreate -d $@

.PHONY: mongo-rs
mongo-rs:
	if [ ! -d $(VOLUME_PREFIX)/$@ ]; then mkdir -p $(VOLUME_PREFIX)/$@; fi
	cd $@ && docker compose -p ${PROJECT_NAME} up --force-recreate -d mongo-replica-setup mongo1 mongo2 mongo3

.PHONY: minio
minio:
	if [ ! -d $(VOLUME_PREFIX)/$@ ]; then mkdir -p $(VOLUME_PREFIX)/$@; fi
	cd $@ && docker compose -p ${PROJECT_NAME} up --force-recreate -d minio-proxy minio1 minio2 minio3 minio4

.PHONY: stop
stop:
	docker compose -p ${PROJECT_NAME} stop $(all) $(others) traefik shadowsocks-proxy postgres
	cd etcd && docker compose stop
	cd elastic && docker compose stop
