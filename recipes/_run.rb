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
container_dns = node['docker-manage']['container']['dns']
container_ports = node['docker-manage']['container']['ports']
dir_volumes = node['docker-manage']['container']['volumes']
container_volumes = Array[]

# Create directories for shared volumes if any
dir_volumes.each do |local,container|
  directory local do
    owner 'root'
    group 'root'
    mode '0766'
    action :create
    recursive true
    not_if { Dir.exist? ("#{local}") }
  end
  container_volumes.push("#{local}:#{container}")
end.empty? and begin
  log "No volumes found for container"
end

# Run the container exposing ports and sharing volumes
docker_container "#{image_name}" do
  image "#{image_name}"
  tag "#{image_tag}"
  detach true
  hostname "#{image_name}.#{node['hostname']}"
  dns container_dns
  port container_ports
  volume container_volumes
  action :run
  not_if "docker start #{image_name}"
end

