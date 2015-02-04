#
# Cookbook Name:: docker-manage
# Recipe:: _load
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

docker_containers = node['docker-manage']['container']['names']
bag = "#{node['docker-manage']['container']['data_bag']}"

docker_containers.each do |container|

  # Load container config from data_bag
  docker = data_bag_item( bag, container)
  
  image_dir = "#{docker['image']['dir']}"
  image_name = "#{docker['image']['name']}"
  image_tag = "#{docker['image']['tag']}"
  image_source = "#{docker['image']['source']}"
  image_checksum = "#{docker['image']['checksum']}"
  
  # Create a folder to store the image
  directory image_dir do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
    recursive true
    not_if { Dir.exist? ("#{image_dir}") }
  end
  
  # Get the image.tar from a remote or local source:
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
 
end 
