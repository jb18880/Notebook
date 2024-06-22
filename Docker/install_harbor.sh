#!/bin/bash 
#harbor下载地址
#https://github.com/goharbor/harbor/releases

IP_ADDRESS=10.0.0.158
HARBOR_PASSWORD=123456
wget https://github.com/goharbor/harbor/releases/download/v2.11.0/harbor-offline-installer-v2.11.0.tgz
tar xf harbor-offline-installer-v2.5.2.tgz -C /usr/local/

mv /usr/local/harbor/harbor.yml.tmpl /usr/local/harbor/harbor.yml

sed -i "s/^hostname: reg.mydomain.com/hostname: ${IP_ADDRESS}/" /usr/local/harbor/harbor.yml
sed -i 's/^https:$/#https:/' /usr/local/harbor/harbor.yml
sed -i 's/port: 443/#port: 443/' /usr/local/harbor/harbor.yml
sed -i 's/certificate/#certificate/' /usr/local/harbor/harbor.yml 
sed -i 's/private_key/#private_key/' /usr/local/harbor/harbor.yml
sed -i "s/harbor_admin_password: Harbor12345/harbor_admin_password: ${HARBOR_PASSWORD}/" /usr/local/harbor/harbor.yml

cat > /etc/docker/daemon.json <<EOF
{
	"registry-mirrors": ["https://9871944d085e4817a11247169cc16509.mirror.swr.myhuaweicloud.com"],
	"insecure-registries": ["hjb.com", "${IP_ADDRESS}"]
}
EOF

bash  /usr/local/harbor/install.sh


cat > /lib/systemd/system/harbor.service <<EOF
[Unit]
Description=Harbor
After=docker.service systemd-networkd.service systemd-resolved.service
Requires=docker.service
Documentation=http://github.com/vmware/harbor
[Service]
Type=simple
Restart=on-failure
RestartSec=5
ExecStart=/usr/local/bin/docker-compose -f /usr/local/harbor/docker-compose.yml up
ExecStop=/usr/local/bin/docker-compose -f /usr/local/harbor/docker-compose.yml down
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now harbor
