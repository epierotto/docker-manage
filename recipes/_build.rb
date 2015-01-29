#
# Cookbook Name:: docker-manage
# Recipe:: _build
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "docker"

build_dir = "#{node['docker-manage']['build']['dir']}"
build_timeout = node['docker-manage']['build']['timeout']
branch_name = "#{node['docker-manage']['image']['branch']}"
image_dir = "#{node['docker-manage']['image']['dir']}"
image_name = "#{node['docker-manage']['image']['name']}"
image_tag = "#{node['docker-manage']['image']['tag']}"
image_repository = "#{node['docker-manage']['image']['repository']}"
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
#  reference "master" 
#  checkout_branch "master"
  action :checkout
#  notifies :build, "docker_image[#{image_name}]", :immediately
#   user "user"
#   group "test"
end

docker_image "#{image_name}" do
  tag "#{image_tag}"
  source "#{build_dir}"
  cmd_timeout build_timeout
  action :build_if_missing
  notifies :save, "docker_image[#{image_name}]"
end

docker_image "#{image_name}" do
  destination "#{image_dir}/#{image_name}.tar"
  tag "#{image_tag}"
  action :nothing
end
