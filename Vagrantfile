Vagrant.configure("2") do |config|
  #
  # Descomentar si estamos detras de un proxy
  #
  #if Vagrant.has_plugin?("vagrant-proxyconf")
  #  config.proxy.http     = "http://192.168.150.17:8080"
  #  config.proxy.https    = "http://192.168.150.17:8080"
  #  config.proxy.no_proxy = "localhost,127.0.0.1"
  #end  
  
  config.vm.define "ingest01" do |ingest01|
    ingest01.vm.box = "centos/7"
    ingest01.vm.hostname = "ingest01.local"
    ingest01.vm.network "private_network", ip: "10.0.200.3"
    ingest01.vm.provision "shell", path: "ingest.sh"
    ingest01.vm.provider "virtualbox" do |vb|
      vb.name = "ingest01"
      vb.memory = "2048"
      vb.cpus = 2
    end    
  end

  config.vm.define "data01" do |data01|
    data01.vm.box = "centos/7"
    data01.vm.hostname = "data01.local"
	data01.vm.provision "shell", path: "server.sh"
    data01.vm.network "private_network", ip: "10.0.200.2"
    data01.vm.provider "virtualbox" do |vb|
      vb.name = "data01"
      vb.memory = "1048"
      vb.cpus = 2
    end    
  end
  


  
  config.vm.define "client01" do |client01|
    client01.vm.box = "centos/7"
    client01.vm.hostname = "client01.local"
    client01.vm.network "private_network", ip: "10.0.200.4"
    client01.vm.provision "shell", path: "client.sh"
    client01.vm.provider "virtualbox" do |vb|
      vb.name = "client01"
      vb.memory = "1048"
      vb.cpus = 2
    end    
  end
  
end
