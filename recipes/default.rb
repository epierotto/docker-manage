#
# Cookbook Name:: docker-manage
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "docker-manage::_build"

include_recipe "docker-manage::_run"

#include_recipe "docker-manage::_remove"

