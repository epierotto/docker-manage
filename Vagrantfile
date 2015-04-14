# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # Set the version of chef to install using the vagrant-omnibus plugin
  config.omnibus.chef_version = "11.4.0"

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
        "docker" => {
          "version" => '1.4.1-3.el6',
	  "options" => '--insecure-registry 10.0.0.10:5000'
        },
        "docker-manage" => {
          "containers" => {
            "data_bags" => {
		"docker_registry" => ["registry"]
#		"docker_chef" => ["chef-server"],
#		"docker_gitlab" => ["gitlab"]
		}
          }
        }
      }
      chef.run_list = [
#        "recipe[yum-epel]",
#        "recipe[docker-manage::_build]",
        "recipe[docker-manage::_run]"
#        "recipe[docker-manage::_pull]"
        ]
    end
  end

end
