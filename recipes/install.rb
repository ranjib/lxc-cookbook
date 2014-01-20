include_recipe 'apt'
include_recipe 'build-essential'

apt_repository 'lxc' do
  uri          'http://ppa.launchpad.net/ubuntu-lxc/daily'
  distribution node['lsb']['codename']
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          'C300EE8C'
end

%w{ liblxc0 lxc lxc-dev lxc-templates lxctl python3-lxc}.each do |pkg|
  package pkg
end

lxc_gem_path = ::File.join(Chef::Config[:file_cache_path],'ruby-lxc-0.1.0.gem')

cookbook_file lxc_gem_path do
  source 'ruby-lxc-0.1.0.gem'
end

chef_gem 'ruby-lxc' do
  source lxc_gem_path
end
