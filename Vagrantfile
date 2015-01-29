# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # Set the version of chef to install using the vagrant-omnibus plugin
  config.omnibus.chef_version = :latest

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  config.berkshelf.berksfile_path = "Berksfile"  

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = 'opscode-ubuntu-12.04'
  config.vm.box = 'opscode-centos-6.6'
  
  config.vm.hostname = "dockermanage"
  
  # Give it some power...
  config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id,
                        '--cpus', '2',
                        '--memory', '1024',]
  end
  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box"

  config.vm.define :bootstrap, primary: true do |guest|
    guest.vm.network :private_network, ip: '10.0.0.10'
    guest.vm.provision :chef_solo do |chef|
      chef.json = {
        "docker-manage" => {
	  "build" => {
		"dir" => "/etc/docker/docker-manage/build"
		},
          "image" => {
		"dir" => "/etc/docker/docker-manage/images",
		"repository" => "https://github.com/epierotto/docker-rabbitmq.git",
		"name" => "rabbitmq",
		"tag" => "latest",
		"source" => "file:///etc/docker/docker-manage/images/rabbitmq.tar",
		"checksum" => "d6091b2688edfc8561b54e1d9db22d2a466bc78fd1f40d702c86cef3b5ae1a71"
        	},
	  "container" => {
	  	"ports" => ['5671:5671','5672:5672','15672:15672'],
		# 		local dir  =>  container dir
		"volumes" => {  
				#"/data/log" => "/data/log",
				#"/data/mnesia" => "/data/mnesia",
				#"/etc/rabbitmq" => "/etc/rabbitmq"
              			}
	  	}
	}
      }
      chef.run_list = [
        "recipe[docker-manage]"
        ]
    end
  end
end
