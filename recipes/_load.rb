#
# Cookbook Name:: docker-manage
# Recipe:: _load
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

data_bags = node['docker-manage']['containers']['data_bags']

data_bags.keys.each.any? do |data_bag|
  data_bags[data_bag].each.any? do |container|
    # Load container config from data_bag
    docker_container = data_bag_item(data_bag, container)

    if docker_container['image_load'] == true

      image_name = docker_container['image_name']
      input = docker_container['image_conf']['input']

      if defined?(docker_container['image_conf']['tag'])
        image_tag = docker_container['image_conf']['tag']
      else
        image_tag = 'latest'
      end

      # Load the image from given tar
      docker_image image_name do
        input input
        action :load
        not_if "docker history #{image_name}:#{image_tag}"
      end
    end
  end
end
