require 'chef/resource/lwrp_base'
require 'chef/provider/lwrp_base'
if defined?(ChefSpec)
  def setup_container_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('container_user', :create, resource_name)
  end
end

class Chef::Resource::ContainerUser < Chef::Resource::LWRPBase
  self.resource_name = 'container_user'
  attribute :user, kind_of: String, name_attribute: true
  attribute :user_password, kind_of: String, name_attribute: true
  attribute :create_user, kind_of: [TrueClass, FalseClass], default: true
  attribute :home_dir, kind_of: String, required: true
  attribute :veth_limit, kind_of: Integer, default: 100
  actions :setup
  default_action :setup
end

class Chef::Provider::ContainerUser < Chef::Provider::LWRPBase
  provides :container_user

  def whyrun_supported?
    true
  end

  use_inline_resources

  def action_setup
    home_dir = new_resource.home_dir
    container_user = new_resource.user
    limit = new_resource.veth_limit
    usernet_file = '/etc/lxc/lxc-usernet'
    line = "#{container_user} veth lxcbr0 #{limit}"
    if new_resource.create_user
      user container_user do
        home home_dir
        shell '/bin/bash'
        password new_resource.user_password if new_resource.user_password
        supports(manage_home: true)
      end
    end

    %w{
      .config
      .local
      .local/share
      .cache
      lxc.conf.d
      .config/lxc
      .local/share/lxc
      .local/share/lxcsnaps
      .cache/lxc
      }.each do |dir|
      directory "#{home_dir}/#{dir}" do
        user container_user
        group container_user
        mode 0775
      end
    end

    subuid_start, subuid_range = ::File.read('/etc/subuid').scan(/#{container_user}:(\d+):(\d+)/).flatten
    subgid_start, subgid_range = ::File.read('/etc/subgid').scan(/#{container_user}:(\d+):(\d+)/).flatten

    template "#{home_dir}/.config/lxc/default.conf" do
      owner container_user
      group container_user
      mode 0644
      source 'lxc.conf.erb'
      variables(
        subuid_start: subuid_start,
        subuid_range: subuid_range,
        subgid_start: subgid_start,
        subgid_range: subgid_range
      )
    end

    file "#{home_dir}/.config/lxc/lxc.conf" do
      owner container_user
      group container_user
      mode 0644
      content "lxc.lxcpath = #{home_dir}"
    end


    ruby_block 'update lxc-usernet' do
      block do
        ::File.open(usernet_file, 'a+') do |f|
          f.write("#{line}\n")
        end
      end
      not_if do
        ::File.exist?(usernet_file) and ::File.read(usernet_file).lines.any?{|l|l.chomp == line}
      end
    end

    file '/etc/lxc/lxc-usernet' do
      owner 'root'
      group 'root'
      mode 0644
    end
  end
end
