#
# Cookbook Name:: docker-manage
# Recipe:: _run
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#


include_recipe "docker"
include_recipe "docker-manage::_load"
image_name = "#{node['docker-manage']['image']['name']}"
image_tag = "#{node['docker-manage']['image']['tag']}"

# Load the image
#docker_image "#{image_name}" do
#  input "#{image_dir}/#{image_name}.tar"
#  action :load
##  only_if { File.exists?(aspnet_regiis) }
#end

# Run the redis container exposing ports
docker_container "#{image_name}" do
  image "#{image_name}"
  tag "#{image_tag}"
  detach true
  hostname "#{image_name}.#{node['hostname']}"
  port '6379:6379'
  action :run
  not_if "docker start #{image_name}"
end

