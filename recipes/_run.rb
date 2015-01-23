#
# Cookbook Name:: docker-manage
# Recipe:: _run
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

# Check that docker is installed
include_recipe "docker"

# Checks that the image is loaded
include_recipe "docker-manage::_load"

# Load attributes for container configuration
image_name = "#{node['docker-manage']['image']['name']}"
image_tag = "#{node['docker-manage']['image']['tag']}"
container_ports = node['docker-manage']['container']['ports']

# Run the redis container exposing ports
docker_container "#{image_name}" do
  image "#{image_name}"
  tag "#{image_tag}"
  detach true
  hostname "#{image_name}.#{node['hostname']}"
  port container_ports
  action :run
  not_if "docker start #{image_name}"
end

