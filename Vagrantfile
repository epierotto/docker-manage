# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # Set the version of chef to install using the vagrant-omnibus plugin
  config.omnibus.chef_version = :latest

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  config.berkshelf.berksfile_path = "Berksfile"  
 

  #### Docker1 definition 
  config.vm.define :docker1 do |docker1|
    docker1.vm.box = 'opscode-centos-6.6'
    docker1.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box"
    docker1.vm.network :private_network, ip: '10.0.0.10'
    docker1.vm.hostname = 'docker1'
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id,
                        '--cpus', '2',
                        '--memory', '1024',]
        end
    
    docker1.vm.provision :chef_solo do |chef|
      chef.data_bags_path = "test/data_bags"
      chef.log_level = :info #:debug
      chef.json = {
        "consul" => {
          "serve_ui" => true,
          "bootstrap_expect" => 2,
          "retry_on_join" => true,
          "bind_interface" => "eth1",
          "advertise_addr" => "10.0.0.10",
          "service_mode" => "cluster",
          "servers" => ["10.0.0.10","10.0.0.11","10.0.0.12"]
        },
        "docker" => {
          "version" => '1.4.1-3.el6'
        },
        "docker-manage" => {
          "container" => {
            "names" => ["redis","rabbitmq1","sensu_server","sensu_api","uchiwa"],
            "data_bag" => "docker_containers"
          }
        },
        "consul-manage" => {
          "service" => {
            "names" => ["redis1","rabbitmq","rabbitmq1","sensu_server","sensu_api","uchiwa"],
            "data_bag" => "consul_services"
          }
        }
      }
      chef.run_list = [
        "recipe[yum-epel]",
        "recipe[consul]",
        "recipe[consul::ui]",
        "recipe[consul::dns]",
        "recipe[consul-manage::_define]",
        "recipe[docker-manage::_build]",
        "recipe[docker-manage::_run]"
        ]
    end
  end

  #### Docker2 definition
  config.vm.define :docker2 do |docker2|
    docker2.vm.box = 'opscode-centos-6.6'
    docker2.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box"
    docker2.vm.network :private_network, ip: '10.0.0.11'
    docker2.vm.hostname = 'docker2'
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id,
                        '--cpus', '2',
                        '--memory', '1024',]
        end
    docker2.vm.provision :chef_solo do |chef|
      chef.data_bags_path = "test/data_bags"
      chef.log_level = :info #:debug
      chef.json = {
        "consul" => {
          "serve_ui" => true,
          "bind_interface" => "eth1",
          "bootstrap_expect" => 2,
          "retry_on_join" => true,
          "advertise_addr" => "10.0.0.11",
          "service_mode" => "cluster",
          "servers" => ["10.0.0.10","10.0.0.11","10.0.0.12"]
        },
        "docker" => {
          "version" => '1.4.1-3.el6'
        },
        "docker-manage" => {
          "container" => {
            "names" => ["redis","rabbitmq2","sensu_server","sensu_api","uchiwa"],
            "data_bag" => "docker_containers"
          }
        },
        "consul-manage" => {
          "service" => {
            "names" => ["redis2","rabbitmq","rabbitmq2","sensu_server","sensu_api","uchiwa"],
            "data_bag" => "consul_services"
          }
        }
      }
      chef.run_list = [
        "recipe[yum-epel]",
        "recipe[consul]",
        "recipe[consul::ui]",
        "recipe[consul::dns]",
        "recipe[consul-manage::_define]",
        "recipe[docker-manage::_build]",
        "recipe[docker-manage::_run]"
        ]
    end
  end

  #### Docker3 definition
  config.vm.define :docker3 do |docker3|
    docker3.vm.box = 'opscode-centos-6.6'
    docker3.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box"
    docker3.vm.network :private_network, ip: '10.0.0.12'
    docker3.vm.hostname = 'docker3'
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id,
                        '--cpus', '2',
                        '--memory', '1024',]
        end
    docker3.vm.provision :chef_solo do |chef|
      chef.data_bags_path = "test/data_bags"
      chef.log_level = :info #:debug
      chef.json = {
        "consul" => {
          "serve_ui" => true,
          "bind_interface" => "eth1",
          "bootstrap_expect" => 2,
          "retry_on_join" => true,
          "advertise_addr" => "10.0.0.12",
          "service_mode" => "cluster",
          "servers" => ["10.0.0.10","10.0.0.11","10.0.0.12"]
        },
        "docker" => {
          "version" => '1.4.1-3.el6'
        },
        "docker-manage" => {
          "container" => {
            "names" => ["redis","rabbitmq3","sensu_server","sensu_api","uchiwa"],
            "data_bag" => "docker_containers"
          }
        },
        "consul-manage" => {
          "service" => {
            "names" => ["redis3","rabbitmq","rabbitmq3","sensu_server","sensu_api","uchiwa"],
            "data_bag" => "consul_services"
          }
        }
      }
      chef.run_list = [
        "recipe[yum-epel]",
        "recipe[consul]",
        "recipe[consul::ui]",
        "recipe[consul::dns]",
        "recipe[consul-manage::_define]",
        "recipe[docker-manage::_build]",
        "recipe[docker-manage::_run]"
        ]
    end
  end


  #### Docker4 definition
  config.vm.define :docker4 do |docker4|
    docker4.vm.box = 'opscode-centos-6.6'
    docker4.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box"
    docker4.vm.network :private_network, ip: '10.0.0.13'
    docker4.vm.hostname = 'docker4'
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id,
                        '--cpus', '1',
                        '--memory', '512',]
        end
    docker4.vm.provision :chef_solo do |chef|
      chef.data_bags_path = "test/data_bags"
      chef.log_level = :info #:debug
      chef.json = {
        "consul" => {
          "serve_ui" => true,
          "bind_interface" => "eth1",
          "bootstrap_expect" => 2,
          "retry_on_join" => true,
          "advertise_addr" => "10.0.0.13",
          "service_mode" => "cluster",
          "servers" => ["10.0.0.10","10.0.0.11","10.0.0.12"]
        },
        "docker" => {
          "version" => '1.4.1-3.el6'
        },
        "docker-manage" => {
          "container" => {
            "names" => ["client1","client2","client3"],
            "data_bag" => "docker_containers"
          }
        },
        "consul-manage" => {
          "service" => {
            "names" => [],
            "data_bag" => "consul_services"
          }
        }
      }
      chef.run_list = [
        "recipe[yum-epel]",
        "recipe[consul]",
        "recipe[consul::ui]",
        "recipe[consul::dns]",
        "recipe[consul-manage::_define]",
        "recipe[docker-manage::_build]",
        "recipe[docker-manage::_run]"
        ]
    end
  end
end
