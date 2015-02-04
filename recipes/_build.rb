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

puts "#{build_dir}"

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
  not_if { File.exist? ("#{image_dir}/#{image_name}.tar") }
end
