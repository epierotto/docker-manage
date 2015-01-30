#
# Cookbook Name:: docker-manage
# Recipe:: _remove
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

image_name = "#{node['docker-manage']['image']['name']}"

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
