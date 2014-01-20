
require 'chef/resource'
require 'chef/provider'

class Chef
  class Resource
    class Container < Chef::Resource

      identity_attr :container_name

      def initialize(name, run_context = nil)
        super
        @resource_name = :container
        @container_name = name
        @options = {}
        @provider = Chef::Provider::Container
        @action = :create
        @allowed_actions += [:start, :stop, :destroy, :create]
      end

      def container_name(arg = nil)
        set_or_return(:container_name, arg, kind_of: [ String ] )
      end

      def options(arg = nil)
        set_or_return(:options, arg, kind_of: [ Hash ] )
      end
    end
  end
  class Provider
    class Container < Chef::Provider

      attr_reader :ct

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        require 'lxc'
        @ct = LXC::Container.new(new_resource.container_name)
        if (new_resource.action == 'start') or (new_resource.action == 'stop')
          raise ArgumentError, 'Can not start or stop non-existent container'
        end
      end

      def action_create
        unless ct.defined?
          converge_by("create container '#{ct.name}'") do
            opts = @new_resource.options
            template = opts[:template] || 'ubuntu'
            block_device = opts[:block_device] || nil
            template_options = opts[:template_options] || []
            flags = opts[:flags] || 0
            ct.create(template, block_device, flags, template_options)
          end
        end
      end

      def action_stop
        if ct.running?
          converge_by("stop container '#{ct.name}'") do
            ct.stop
          end
        end
      end

      def action_start
        unless ct.running?
          converge_by("start container '#{ct.name}'") do
            ct.start
          end
        end
      end

      def action_destroy
        if ct.defined?
          converge_by("destroy container '#{ct.name}'") do
            ct.destroy
          end
        end
      end
    end
  end
end
