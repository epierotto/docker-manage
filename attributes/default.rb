#
# Cookbook Name:: docker-manage
# Attributes:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

default['docker-manage']['dir']['build'] = "/etc/docker/docker-manage/build"
default['docker-manage']['dir']['images'] = "/etc/docker/docker-manage/images"
default['docker-manage']['image']['name'] = "redis"
default['docker-manage']['image']['tag'] = "latest"
default['docker-manage']['image']['build'] = true
default['docker-manage']['image']['source'] = "file:///etc/docker/docker-manage/images/redis.tar"
default['docker-manage']['image']['checksum'] = "d6091b2688edfc8561b54e1d9db22d2a466bc78fd1f40d702c86cef3b5ae1a71"
default['docker-manage']['container']['ports'] = '6379:6379'


