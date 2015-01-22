#
# Cookbook Name:: docker-manage
# Recipe:: _build
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "docker"

image_dir = "#{node['docker-manage']['dir']['images']}"
image_name = "#{node['docker-manage']['image']['name']}"
image_tag = "#{node['docker-manage']['image']['tag']}"

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

#git "#{Chef::Config[:file_cache_path]}/docker-testcontainerd" do
#  repository 'git@github.com:bflad/docker-testcontainerd.git'
#  notifies :build, 'docker_image[bflad/testcontainerd]', :immediately
#end

docker_image "#{image_name}" do
  tag "#{image_tag}"
  action :pull_if_missing
  cmd_timeout 240
end

#docker_image 'myImage' do
#  source 'example.com/foo/myImage'
#  tag 'docker-manage'
#  action :pull_if_missing
#end


docker_image "#{image_name}" do
  destination "#{image_dir}/#{image_name}.tar"
  tag "#{image_tag}"
  action :save
  not_if { File.exist? ("#{image_dir}/#{image_name}.tar")}
end
