#
# Cookbook Name:: docker-manage
# Recipe:: _build
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "docker"

docker_containers = node['docker-manage']['container']['names']
bag = "#{node['docker-manage']['container']['data_bag']}"

docker_containers.each do |container|
 
  # Load container config from data_bag
  docker = data_bag_item( bag, container)

  build_dir = "#{docker['build']['dir']}"
  build_timeout = docker['build']['timeout']
  branch_name = "#{docker['image']['branch']}"
  image_dir = "#{docker['image']['dir']}"
  image_name = "#{docker['image']['name']}"
  image_tag = "#{docker['image']['tag']}"
  image_repository = "#{docker['image']['repository']}"
  dirs = ["#{build_dir}","#{image_dir}"]

  # Create the folder to build and store the image
  dirs.each do |path|
    directory path do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
      recursive true
      not_if { Dir.exist? ("#{path}") }
    end
  end

  package "git" 
  
  git "#{build_dir}" do
    repository "#{image_repository}"
    action :checkout
  end
  
  docker_image "#{image_name}" do
    tag "#{image_tag}"
    source "#{build_dir}"
    cmd_timeout build_timeout
    action :build_if_missing
  #  notifies :save, "docker_image[#{image_name}]"
  end
  
  if File.exist? ("#{image_dir}/#{image_name}.tar")
    str = "*" * 100
    Chef::Log.warn("\n#{str}\n*\n* WARNING!!\n* NOT SAVING \"#{image_name}.tar\" DUE TO \"#{image_dir}/#{image_name}.tar\" ALREADY EXIST.\n*\n#{str}")
  end
  
  docker_image "#{image_name}" do
    destination "#{image_dir}/#{image_name}.tar"
    tag "#{image_tag}"
    action :save
#    notifies :run, "execute[remove-image]", :immediately
    not_if { File.exist? ("#{image_dir}/#{image_name}.tar") }
  end

end
