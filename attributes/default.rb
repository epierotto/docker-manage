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


