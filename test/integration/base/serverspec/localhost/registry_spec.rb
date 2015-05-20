require 'spec_helper'

describe service('docker') do
  it { should be_running }
end

describe docker_image('registry:0.9.1') do
  it { should be_present }
end

describe docker_container('registry') do
  it { should be_running }
end

describe port(5000) do
  it { should be_listening.with('tcp') }
end
