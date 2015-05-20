#
# Cookbook Name:: docker-manage
# Recipe:: _backup
#
# Copyright (c) 2015 Exequiel Pierotto, All Rights Reserved.
#

containers = node['docker-manage']['containers']['backup']

containers.each.key.any? do |container|
  # Save current timestamp
  timestamp = Time.new.strftime('%Y%m%d%H')
  repository = container['repository']

  if defined?(container['tag'])
    tag = container['tag']
  else
    tag = 'latest'
  end

  if defined?(container['repository'])
    image_name = "#{repository}/#{container}"
  else
    image_name = container
  end

  tags = [timestamp, tag]

  tags.each do |t|
    # Commit container changes
    docker_container container do
      repository image_name
      tag t
      action :commit
      not_if "docker history #{repository}/#{container}:#{timestamp}"
    end

    # Push the image with the new tag
    docker_image container do
      image_name image_name
      tag t
      action :push
      not_if "docker history #{repository}/#{container}:#{timestamp}"
    end
  end
end
