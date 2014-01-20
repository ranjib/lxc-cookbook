## LXC cookbook
[Chef](http://www.getchef.com/chef/) cookbook for managing lxc (linux containers)

### Usage
This cookbook provides `container` resource/providers. Currently its
only tested on ubuntu 14.04. This cookbook uses [native ruby bindings](https://github.com/lxc/ruby-lxc)
for managing containers.

Following will create a ubuntu container named `test-1`

```ruby
container 'test-1'

```

And following will create and start a ubuntu 10.04 container
```ruby
container 'test-2' do
  options(template: 'ubuntu', template_options: ['-r lucid'])
  action [:create, :start]
end
```

### Details
`container` resource can have following actions:
- create _default_
- destroy
- start
- stop

And following attributes
- container_name _name attribute, default to resource name_
- options _a hash of action specific parameters_

The _options_ attribute can take following parameters (as hash)
- for _create_ action:
  - template: name of the template that will be used for creating the container (e.g. ubuntu, fedora, oracle etc). Default is ubuntu.
  - template_options: an array containing addiotional arguments that will be passed to template (use `lxc-create -t foo --help` to get the list of supported options for individual templates). Default is an empty array
  - block_device: The backing storage device (e.g lvm, zfs etc). Default is nil
  - flags: An integer flag passed to lxc-crate (currently only LXC::LXC_CREATE_QUIET is available)

