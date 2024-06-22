#!/bin/bash

yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2

cat > /etc/yum.repos.d/BaseOS.repo <<EOF

[BaseOS]
name=BaseOS
baseurl=http://10.0.0.164:8081/repository/rocky8-yum/BaseOS/x86_64/os/
gpgcheck=0

[AppStream]
name=AppStream
baseurl=http://10.0.0.164:8081/repository/rocky8-yum/AppStream/x86_64/os/
gpgcheck=0


[extras]
name=extras
baseurl=http://10.0.0.164:8081/repository/rocky8-yum/extras/x86_64/os/
gpgcheck=0

[PowerTools]
name=Power Tools
baseurl=http://10.0.0.164:8081/repository/rocky8-yum/PowerTools/x86_64/os/
gpgcheck=0

[epel]
name=epel
baseurl=http://10.0.0.164:8081/repository/epel-rocky/
gpgcheck=0

[docker-ce]
name=docker-ce
baseurl=http://10.0.0.164:8081/repository/docker-ce/
gpgcheck=0

EOF


yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable --now docker