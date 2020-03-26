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
yum install --enablerepo=elasticsearch elasticsearch logstash kibana apm-server java-11-openjdk java-11-openjdk-devel -y
echo "[+] Elasticsearch installed"

echo "[+] Elasticsearch: config"
cat <<EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: aeacluster
node.name: ingest01.local
network.host: _eth1_
discovery.seed_hosts: ["ingest01.local"]
cluster.initial_master_nodes: ["ingest01.local"]
node.master: true
node.data: false
node.ingest: true
xpack.ml.enabled: true
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
EOF

echo "[+] Kibana: config"
cat <<EOF > /etc/kibana/kibana.yml
server.host: 0.0.0.0
server.basePath: "/kibana"
server.rewriteBasePath: true
server.name: "ingest01.local"
elasticsearch.hosts: [ "http://10.0.200.3:9200" ]
logging.dest: /var/log/kibana.log
EOF

echo "[+] Logstash: config"
cat <<EOF > /etc/logstash/conf.d/logstash.conf
input {
    beats {
        port => 5044
    }
}
filter {
  if ([class] == "business") {
    json {
        source => "message"
    }
    geoip {
      source => "[operationId][clientIP]"
    }
    date {
      match => [ "timestamp", "ISO8601" ]
      target => "@timestamp"
    }
    mutate {
      remove_field => [ "message" ]
      remove_field => [ "timestamp" ]
      remove_field => [ "beat" ]
      remove_field => [ "tags" ]
      remove_field => "[operationId][clientIP]"
      remove_field => [ "type" ]
      remove_field => "[@metadata][type]"
      lowercase => [ "realm" ]
      lowercase => [ "domain" ]
      lowercase => [ "service" ]
      lowercase => [ "operation" ]
      lowercase => [ "environment" ]

      # Se recoge el campo clientID en las trazas de oauth, en el mismo field que las trazas del reino de checkout
      rename => { "[trace][parameters_object][client_id_string]" => "[trace][parameters_object][clientContext_object][clientId_string]" }
    }
  }
}
output {
  if ([class] == "business") {
    elasticsearch {
	    hosts => "http://10.0.200.3:9200/"
	    index => "logstash-%{[class]}-%{[realm]}-%{[domain]}-%{[service]}-%{[environment]}-%{[@metadata][version]}-%{+YYYY.MM}"
	    document_id => '%{[operation]}-%{[operationId][requestId]}-%{[@timestamp]}'
    }
  }
  else {
    elasticsearch {
	    hosts => "http://10.0.200.3:9200/"
	    index => "logstash-%{[@metadata][version]}-%{+YYYY.MM}"
     }
  }
}
EOF

touch /var/log/kibana.log
chown kibana:kibana /var/log/kibana.log


cat <<EOF > /etc/apm-server/apm-server.yml
apm-server:
  host: "10.0.200.3:8200"
output.elasticsearch:
  hosts: ["10.0.200.3:9200"]
EOF


echo "[+] Enabling services"
systemctl enable elasticsearch kibana apm-server logstash
systemctl start elasticsearch kibana apm-server logstash
