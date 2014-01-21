include_recipe 'build-essential'

execute 'apt-get update -y' do
  not_if 'dpkg -s lxc'
end

%w{lxc liblxc0 lxc-templates lxc-dev python3-lxc}.each do |pkg|
  package pkg
end

lxc_gem_path = ::File.join(Chef::Config[:file_cache_path],'ruby-lxc-0.1.0.gem')

cookbook_file lxc_gem_path do
  source 'ruby-lxc-0.1.0.gem'
end.run_action(:create)

gem_package 'ruby-lxc' do
  source lxc_gem_path
  gem_binary '/opt/chef/embedded/bin/gem'
end
