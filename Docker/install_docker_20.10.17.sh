#!/bin/bash

[ -d /etc/yum.repos.d/backup ] || mkdir /etc/yum.repos.d/backup

mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup 2>/dev/null
mv /etc/yum.repos.d/*.bak  /etc/yum.repos.d/backup 2>/dev/null

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

EOF



cat > /etc/yum.repos.d/docker-ce.repo << EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=http://10.0.0.164:8081/repository/docker-ce/
enabled=1
gpgcheck=0
EOF

yum -y install docker-ce-3:20.10.17-3.el8 docker-ce-cli-1:20.10.17-3.el8 containerd.io docker-compose-plugin
systemctl enable --now docker.service
