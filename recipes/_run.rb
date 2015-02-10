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

docker_containers = node['docker-manage']['container']['names']
bag = "#{node['docker-manage']['container']['data_bag']}"

docker_containers.each do |container|

  # Load container config from data_bag
  docker = data_bag_item( bag, container)
  
  # Load attributes for container configuration
  image_name = "#{docker['image']['name']}"
  image_tag = "#{docker['image']['tag']}"
  container_name = "#{docker['container']['name']}"
  container_dns = docker['container']['dns']
  container_env = docker['container']['env']
  container_ports = docker['container']['ports']
  dir_volumes = docker['container']['volumes']
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
    hostname "#{container_name}"
    dns container_dns
    env container_env
    port container_ports
    volume container_volumes
    action :run
    not_if "docker start #{image_name}"
  end
  
end
