#
# Cookbook Name:: docker-manage
# Recipe:: _remove
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
  
  image_name = "#{docker['image']['name']}"
  
  # Remove the container and image after stopping it
  
  str = "*" * 50
  Chef::Log.info("\n#{str}\n*\n* WARNING!!\n* REMOVING \"#{image_name}\" CONTAINER.\n*\n#{str}")
  
  
  docker_container "#{image_name}" do
    force true
    action :remove
    only_if "docker stop #{image_name}"
    notifies :remove, "docker_image[#{image_name}]", :immediately
  end
  
  
  docker_image "#{image_name}" do
    force true
    action :nothing
    no_prune false
  end

end
