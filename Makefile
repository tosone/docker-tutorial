include .env
export $(shell sed 's/=.*//' .env)

export COMPOSE_IGNORE_ORPHANS=True # ignore others container

compose_version = v2.2.3

all = gitea gogs mongo redis mysql influxdb filebrowser jupyter portainer drone-server drone-runner watchtower
others = frps frpc netdata shadowsocks httpbin phpmyadmin

run: ensure-dir traefik frps frpc postgres $(all)

.PHONY: install
install:
	curl -fsSL https://get.docker.com | sh
	$(MAKE) install-docker-compose
	sudo usermod -aG docker $(USER)
	echo "docker and docker-compose installed, now you should exit and login again, then run 'make docker-network'"

.PHONY: install-docker-compose
install-docker-compose:
	sudo curl -L https://github.com/docker/compose/releases/download/$(compose_version)/docker-compose-`uname -s | tr '[:upper:]' '[:lower:]'`-`uname -m` -o /usr/bin/docker-compose
	sudo chmod +x /usr/bin/docker-compose

.PHONY: docker-network
docker-network:
	docker network create $(DOCKER_NETWORK)

.PHONY: ensure-dir
ensure-dir:
	$(foreach dir, $(all), $(shell if [ ! -d $(VOLUME_PREFIX)/$(dir) ]; then mkdir -p $(VOLUME_PREFIX)/$(dir); fi))

.PHONY: $(all) $(others)
$(all) $(others):
	docker-compose up --force-recreate -d $@

.PHONY: shadowsocks-proxy
shadowsocks-proxy:
	cd $@ && sh gen.sh > modules-enabled/shadowsocks.conf
	docker-compose up --force-recreate -d --build $@
	$(RM) $@/modules-enabled/shadowsocks.conf

.PHONY: postgres
postgres: ensure-dir
	cd $@ && sh gen.sh
	if [ ! -d $(VOLUME_PREFIX)/$@ ]; then mkdir -p $(VOLUME_PREFIX)/$@; fi
	if [ ! -d ${VOLUME_PREFIX}/key ]; then mkdir -p ${VOLUME_PREFIX}/key; fi
	sudo cp -r $@ ${VOLUME_PREFIX}/key
	cd ${VOLUME_PREFIX}/key/$@ && sudo chmod 640 server.key && sudo chown 0:70 server.key
	docker-compose up --force-recreate -d $@

.PHONY: traefik
traefik:
	if [ ! -d $(VOLUME_PREFIX)/$@ ]; then mkdir -p $(VOLUME_PREFIX)/$@; fi
	if [ ! -f $(VOLUME_PREFIX)/$@/acme.json ]; then touch $(VOLUME_PREFIX)/$@/acme.json; fi
	sudo chmod 600 $(VOLUME_PREFIX)/$@/acme.json
	docker-compose -f docker-compose-$@.yml up --force-recreate -d $@

.PHONY: etcd
etcd:
	$(shell if [ ! -d $(VOLUME_PREFIX)/etcd/etcd1 ]; then mkdir -p $(VOLUME_PREFIX)/etcd/etcd1; fi)
	$(shell if [ ! -d $(VOLUME_PREFIX)/etcd/etcd2 ]; then mkdir -p $(VOLUME_PREFIX)/etcd/etcd2; fi)
	$(shell if [ ! -d $(VOLUME_PREFIX)/etcd/etcd3 ]; then mkdir -p $(VOLUME_PREFIX)/etcd/etcd3; fi)
	cd $@ && docker-compose up --force-recreate -d

.PHONY: elastic
elastic:
	$(shell if [ ! -d $(VOLUME_PREFIX)/elasticsearch ]; then mkdir -p $(VOLUME_PREFIX)/elasticsearch; fi)
	cd $@ && docker-compose up --force-recreate -d

.PHONY: registry
registry:
	docker run --entrypoint htpasswd httpd:2 -Bbn $(USERNAME) $(SECRETPERSONAL) > registry/auth/htpasswd
	docker-compose up --force-recreate -d $@

.PHONY: upgrade
upgrade:
	docker-compose pull $(all)
	docker-compose -f docker-compose-traefik.yml pull traefik

.PHONY: stop
stop:
	docker-compose stop $(all) $(others) shadowsocks-proxy postgres
	cd etcd && docker-compose stop
	cd elastic && docker-compose stop
	docker-compose -f docker-compose-traefik.yml stop traefik
