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
image_source = "#{node['docker-manage']['image']['source']}"
image_checksum = "#{node['docker-manage']['image']['checksum']}"



remote_file "#{image_dir}/#{image_name}.tar" do
  source "#{image_source}"
  checksum "#{image_checksum}"
  not_if { File.exists?("#{image_dir}/#{image_name}.tar") }
end

# Load the image
docker_image "#{image_name}" do
  input "#{image_dir}/#{image_name}.tar"
  action :load
#  only_if { File.exists?(aspnet_regiis) }
end

