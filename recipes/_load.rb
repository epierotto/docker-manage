#
# Cookbook Name:: docker-manage
# Recipe:: _load
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

image_dir = "#{node['docker-manage']['dir']['images']}"
image_name = "#{node['docker-manage']['image']['name']}"
image_tag = "#{node['docker-manage']['image']['tag']}"

# Load the image
docker_image "#{image_name}" do
  input "#{image_dir}/#{image_name}.tar"
  action :load
#  only_if { File.exists?(aspnet_regiis) }
end

