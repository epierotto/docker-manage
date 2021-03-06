#
# Cookbook Name:: docker-manage
# Recipe:: _build
#
# Copyright (C) 2015 Exequiel Pierotto <epierotto@abast.es>
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'docker'

data_bags = node['docker-manage']['containers']['data_bags']

data_bags.keys.each do |data_bag|
  data_bags[data_bag].each do |container|
    # Load container config from data_bag
    docker_container = data_bag_item(data_bag, container)

    build_dir = docker_container['image_build']['dir']
    build_timeout = docker_container['image_build']['timeout']
    build_repository = docker_container['image_build']['repository']
    image_name = docker_container['image_name']

    if defined?(docker_container['image_conf']['tag'])
      image_tag = docker_container['image_conf']['tag']
    else
      image_tag = 'latest'
    end

    # Create the folder to build and store the image
    directory build_dir do
      mode '0755'
      action :create
      recursive true
      not_if { Dir.exist?(build_dir) }
    end

    package 'git'

    git build_dir do
      repository build_repository
      action :checkout
    end

    docker_image image_name do
      tag image_tag
      source build_dir
      cmd_timeout build_timeout
      action :build_if_missing
    end
  end
end
