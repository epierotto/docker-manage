#
# Cookbook Name:: docker-manage
# Recipe:: _save
#
# Copyright (c) 2015 Exequiel Pierotto, All Rights Reserved.

include_recipe 'docker'

data_bags = node['docker-manage']['containers']['data_bags']

data_bags.keys.each do |data_bag|
  data_bags[data_bag].each do |container|
    # Load container config from data_bag
    docker_container = data_bag_item(data_bag, container)

    save_dir = docker_container['image_save']['dir']
    image_name = docker_container['image_name']

    if defined?(docker_container['image_conf']['tag'])
      image_tag = docker_container['image_conf']['tag']
    else
      image_tag = 'latest'
    end

    directory path do
      mode '0755'
      action :create
      recursive true
      not_if { Dir.exist?(path) }
    end

    if File.exist?("#{save_dir}/#{image_name}.tar")
      str = '*' * 100
      Chef::Log.warn("\n#{str}\n*\n* WARNING!!\n* NOT SAVING \"#{image_name}.tar\" DUE TO \"#{save_dir}/#{image_name}.tar\" ALREADY EXIST.\n*\n#{str}")
    end

    docker_image image_name do
      destination "#{save_dir}/#{image_name}.tar"
      tag image_tag
      action :save
      not_if { File.exist?("#{save_dir}/#{image_name}.tar") }
    end
  end
end
