#
# Cookbook Name:: docker-manage
# Recipe:: _run
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

# Check that docker is installed and properly configured
include_recipe "docker"
#include_recipe "docker-manage::_pull"
#include_recipe "docker-manage::_load"

data_bags = node['docker-manage']['containers']['data_bags']

data_bags.keys.each do |data_bag|

  data_bags[data_bag].each do |container|

    # Load container config from data_bag
    docker_container = data_bag_item( data_bag, container)
    
    image_name = "#{docker_container['image_name']}"

    if docker_container['image_conf']['tag']
      image_tag = "#{docker_container['image_conf']['tag']}"
    else
      image_tag = "latest"
    end
   

    if docker_container['image_load'] == true

      # Load the image from given tar
      input = "#{docker_container['image_conf']['input']}"
      
      docker_image "#{image_name}" do
        input input
        action :load
        not_if "docker history #{image_name}:#{image_tag}"
      end

    elsif docker_container['image_load'] == false
      
      # Pull the image
      docker_image "#{image_name}" do
  
        # Load image config from data_bag
        docker_container['image_conf'].each do |setting, value|
          send(setting, value)
        end
  
        action :pull
  
      end

    end

    # Load attributes for container configuration
    container_name= "#{docker_container['container_name']}"

    # Create directories for shared volumes if any         
    if docker_container['container_conf']['volume']

      docker_container['container_conf']['volume'].each do |volume|

        host_dir, container_dir = volume.split(':')

        unless host_dir.empty?
     
          directory host_dir do
            owner 'root'
            group 'root'
            mode '0777'
            action :create
            recursive true
          end
    
        end
      end
    else
      log "No volumes found for container"
    end

    # Run the container exposing ports and sharing volumes
    docker_container "#{container_name}" do
      image "#{image_name}:#{image_tag}"
      container_name "#{container_name}"
      # Load container config from data_bag
      docker_container['container_conf'].each do |setting, value|
        send(setting, value)
      end

      detach true
      action :run
      not_if "docker start #{container_name}"

    end
  end  
end
