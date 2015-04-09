#
# Cookbook Name:: docker-manage
# Recipe:: _pull
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

data_bags = node['docker-manage']['containers']['data_bags']


data_bags.keys.each do |data_bag|

  data_bags[data_bag].each do |container|

    # Load container config from data_bag
    docker_container = data_bag_item( data_bag, container)

    if docker_container['image_load'] == false

      image_name = "#{docker_container['image_name']}"
     
      if docker_container['image_conf']['tag']
        image_tag = "#{docker_container['image_conf']['tag']}"
      else
        image_tag = "latest"
      end

      # Login in the registry if necessary
      if docker_container['registry']
  
        registry = "#{docker_container['registry']}"
  
        # Registry Login
        docker_registry "#{registry}" do
  
          # Load image config from data_bag
          docker_container['registry_conf'].each do |setting, value|
            send(setting, value)
          end
  
        end
  
      end
  
      # Pull the image
      docker_image "#{image_name}" do
  
        # Load image config from data_bag
        docker_container['image_conf'].each do |setting, value|
          send(setting, value)
        end
  
        action :pull
        #not_if "docker history #{image_name}:#{image_tag}"
  
      end
  
    end

  end

end 
