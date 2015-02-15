%w{
  lxc
  lxc-templates
  lxc-dev
  python3-lxc
  cgmanager-utils
  build-essential
  }.each do |pkg|
  package pkg
end

%w{ruby-lxc lxc-extra chef-lxc}.each do |gem|
  gem_package gem do
    gem_binary '/opt/chef/embedded/bin/gem'
  end
end
