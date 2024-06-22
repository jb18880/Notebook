#!/bin/bash
#docker-compose文件下载地址
#https://github.com/docker/compose/releases

wget https://github.com/docker/compose/releases/download/v2.28.0/docker-compose-linux-x86_64
mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose version
