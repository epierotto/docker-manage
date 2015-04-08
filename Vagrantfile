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
          "version" => "0.4.1",
          "bootstrap_expect" => 2,
          "retry_on_join" => true,
          "bind_interface" => "eth1",
          "advertise_addr" => "10.0.0.10",
          "service_mode" => "cluster",
          "servers" => ["10.0.0.10","10.0.0.11","10.0.0.12"]
        },
        "docker" => {
          "version" => '1.4.1-3.el6',
	  "options" => '--insecure-registry 10.0.0.10:5000'
        },
        "docker-manage" => {
          "containers" => {
            "data_bags" => {
		"docker_registry" => ["registry"],
		"docker_chef" => ["chef-server"],
		"docker_gitlab" => ["gitlab"]
 
			
		}
          }
        },
        "consul-manage" => {
          "service" => {
            "names" => ["redis1","rabbitmq","rabbitmq1","sensu_server","sensu_api","uchiwa"],
            "data_bag" => "consul_services"
          },
	  "watch" => {
	    "service" => {
                        "names" => ["sensu_api","sensu_server"],
                        "data_bag" => "consul_watch_service"
                }
          },
          "handlers" => {
                "packages" => ["nc"],
                "sources" => [],
                "dir" => "/usr/local/consul/handlers/"
          }
        }
      }
      chef.run_list = [
        "recipe[yum-epel]",
#        "recipe[consul]",
#        "recipe[consul::ui]",
#        "recipe[consul-manage::dns]",
#        "recipe[consul-manage::handlers]",
#        "recipe[consul-manage::_define]",
#        "recipe[consul-manage::_watch]",
#        "recipe[docker-manage::_build]",
        "recipe[docker-manage::_run]"
#        "recipe[docker-manage::_pull]"
        ]
    end
  end

end
