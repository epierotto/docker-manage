#
# Cookbook Name:: docker-manage
# Recipe:: _remove
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

# Remove the redis container

docker_container 'redis' do
  action :stop
end


docker_image 'redis' do
  force true
  action :remove
end
