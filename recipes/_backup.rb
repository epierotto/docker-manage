#
# Cookbook Name:: docker-manage
# Recipe:: _backup
#
# Copyright (c) 2015 Exequiel Pierotto, All Rights Reserved.
#

containers = node['docker-manage']['containers']['backup']

containers.each.any? do |container|

   # Save current timestamp
  timestamp = Time.new.strftime('%Y%m%d%H')

  repository = '10.0.0.10:5000'

  tag = 'oso'

  if !system("docker history #{repository}/#{container}:#{timestamp}")

    tags = [timestamp, tag]

    tags.each do |t|

       # Commit container changes
      docker_container container do
	repository "#{repository}/#{container}"
	tag t
	action :commit
      end

       # Push the image with the new tag
      docker_image container do
	image_name "#{repository}/#{container}"
	tag t
        action :push
      end

    end
  end
end
