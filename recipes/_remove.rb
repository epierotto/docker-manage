#
# Cookbook Name:: docker-manage
# Recipe:: _remove
#
# Copyright (C) 2015 Exequiel Pierotto <epierotto@abast.es>
#
# All rights reserved - Do Not Redistribute
#

docker_containers = node['docker-manage']['containers']['remove']

docker_containers.each do |container|
  # Remove the container after stopping it
  str = '*' * 50
  Chef::Log.info("\n#{str}\n*\n* WARNING!!\n* REMOVING \"#{container}\" CONTAINER.\n*\n#{str}")

  docker_container container do
    force true
    action :remove
    only_if "docker stop #{container}"
    notifies :remove, "docker_image[#{container}]", :immediately
  end
end
