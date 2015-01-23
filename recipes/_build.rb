#
# Cookbook Name:: docker-manage
# Recipe:: _build
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "docker"

build_dir = "#{node['docker-manage']['dir']['build']}"
branch_name = "#{node['docker-manage']['image']['branch']}"
image_dir = "#{node['docker-manage']['dir']['images']}"
image_name = "#{node['docker-manage']['image']['name']}"
image_tag = "#{node['docker-manage']['image']['tag']}"
image_repository = "#{node['docker-manage']['image']['repository']}"

# Create a folder to build and store the image
node['docker-manage']['dir'].each do |dir,path|
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

#git "#{Chef::Config[:file_cache_path]}/docker-testcontainerd" do
#  repository 'git@github.com:bflad/docker-testcontainerd.git'
#  notifies :build, 'docker_image[bflad/testcontainerd]', :immediately
#end
#docker_image "#{image_name}" do
#  tag "#{image_tag}"
#  action :pull_if_missing
#  cmd_timeout 240
##  not_if { node['docker-manage']['image']['build'] == true  }
#end

docker_image "#{image_name}" do
  tag "#{image_tag}"
  source "#{build_dir}"
  action :build_if_missing
end

docker_image "#{image_name}" do
  destination "#{image_dir}/#{image_name}.tar"
  tag "#{image_tag}"
  action :save
  not_if { File.exist? ("#{image_dir}/#{image_name}.tar")}
end
