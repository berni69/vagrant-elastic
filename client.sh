#!/bin/bash
echo "[+] Updating system"
#yum update -y 
echo "[+] End of Update"
echo "[+] Setting up DNS"
yum install -y epel-release 
yum install -y nss-mdns net-tools

systemctl enable avahi-daemon
systemctl restart avahi-daemon
echo "[+] End of Setting up DNS"

echo "[+] Installing filebeat"
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat <<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
yum install --enablerepo=elasticsearch filebeat docker -y

echo "[+] Filebeat installed"

systemctl enable filebeat
systemctl start filebeat