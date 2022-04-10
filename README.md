# Docker Tutorial

## Try shadowsocks demo

Make a shadowsocks server in 30 seconds. Test it on Debian buster.

[![asciicast](https://asciinema.org/a/WaGjxoVTRdlyUIkG6BlFRiBWz.svg)](https://asciinema.org/a/WaGjxoVTRdlyUIkG6BlFRiBWz)

After that you can connect this server with `ss://chacha20-ietf-poly1305:123456@192.168.100.1:3600`.

## Service

|Application|ContianerPort|Port|Domain|Database|Admin|Password|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|gitea|3000|443|git.tosone.cn|-|-|-|
|gogs|3000|443|gogs.tosone.cn|-|-|-|
|httpbin|80|443|httpbin.tosone.cn|-|-|-|
|netdata|19999|443|netdata.tosone.cn|-|-|-|
|mongo|27017|27017|mongo.tosone.cn|database|tosone|secret|
|mysql|3306|3306|mysql.tosone.cn|database|tosone|secret|
|redis|6379|6379|redis.tosone.cn|database|tosone|secret|
|postgres|5432|5432|postgres.tosone.cn|database|tosone|secret|
|influxdb|8086|443|influxdb.tosone.cn|database|tosone|secret|
|influxdb|2003|2003|influxdb.tosone.cn|-|-|-|
|frps|9000|9000-10000|frp.tosone.cn|-|-|-|

## Mongo Replica Set

Generate file.key.

``` bash
openssl rand -base64 700 > file.key
chmod 400 file.key
sudo chown 999:999 file.key
```

Connect to the Mongo replica set.

``` bash
mongo "mongodb://tosone:secret@mongo.tosone.cn:30001,mongo.tosone.cn:30002,mongo.tosone.cn:30003/database?replicaSet=rs0&authMechanism=DEFAULT&authSource=database"
```

## Jupyter Notebook Password

``` python
from jupyter_server.auth import passwd
password = passwd()
print(password)
```
