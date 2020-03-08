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


echo "[+] Installing elasticsearch"
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
yum install --enablerepo=elasticsearch elasticsearch -y
echo "[+] Elasticsearch installed"


cat <<EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: aeacluster
node.name: data01.local
network.host: 0.0.0.0
discovery.seed_hosts: ["ingest01.local"]
cluster.initial_master_nodes: ["ingest01.local"]
node.master: false
node.data: true
node.ingest: false
xpack.ml.enabled: false
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
EOF

systemctl enable elasticsearch
systemctl start elasticsearch


