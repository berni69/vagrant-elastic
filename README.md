# vagrant-elastic

## Requirements

In order to run this project you will need at least 5GB of free RAM and the following software:

- Virtualbox (>6.0): https://www.virtualbox.org/wiki/Downloads

- Virtualbox Extension Pack: https://www.virtualbox.org/wiki/Downloads

- Vagrant: https://www.vagrantup.com/downloads.html

## How to run it?
It's simple, you only have to put your logs in the folder "dataset" and run the command:

```
vagrant up
```

This script will setup a full ELK cluster ( ElasticSearch, Kibana, Logstash, Apm-Server).
