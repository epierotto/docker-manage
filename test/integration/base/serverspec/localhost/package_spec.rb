require 'spec_helper'

describe package('docker-io') do
  it { should be_installed }
end

describe service('docker') do
  it { should be_enabled }
end
