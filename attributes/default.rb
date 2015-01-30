#
# Cookbook Name:: docker-manage
# Attributes:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

default['docker-manage']['build']['dir'] = "/etc/docker/docker-manage/build/rabbitmq"
default['docker-manage']['build']['timeout'] = 900
default['docker-manage']['image']['dir'] = "/etc/docker/docker-manage/images/rabbitmq"
default['docker-manage']['image']['repository'] = "https://github.com/epierotto/docker-rabbitmq.git"
default['docker-manage']['image']['branch'] = "master"
default['docker-manage']['image']['name'] = "rabbitmq"
default['docker-manage']['image']['tag'] = "latest"
default['docker-manage']['image']['build'] = true
default['docker-manage']['image']['source'] = "file:///etc/docker/docker-manage/images/rabbitmq/rabbitmq.tar"
default['docker-manage']['image']['checksum'] = "d6091b2688edfc8561b54e1d9db22d2a466bc78fd1f40d702c86cef3b5ae1a71"
# Container DNS config
default['docker-manage']['container']['dns'] = [
#							node['ipaddress']
						]
# Publish ports						
default['docker-manage']['container']['ports'] = [
#							'5671:5671',
#							'5672:5672',
#							'15672:15672'
						]
# Volumes to mount on the container			local dir  =>  container dir 
default['docker-manage']['container']['volumes'] = {
							#"/data/log" => "/data/log",
							#"/data/mnesia" => "/data/mnesia",
							#"/etc/rabbitmq" => "/etc/rabbitmq"
						   }


