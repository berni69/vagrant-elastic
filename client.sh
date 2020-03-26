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

echo "[+] Filebeat: config"
cat <<EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  paths:
    - /logs/*/*.log
  encoding: plain
  scan_frequency: 10s
  close_inactive: 24h
  ignore_older: 48h
  fields:
    environment: production
    class: business
  fields_under_root: true

#----------------------------- Logstash output --------------------------------
output.logstash:
  # The Logstash hosts
  hosts: ["ingest01.local:5044"]
  worker: 2
  compression_level: 3

logging.level: warning
EOF

mkdir -p /logs/dataset

echo "[+] Enabling services"
systemctl enable filebeat
systemctl start filebeat
