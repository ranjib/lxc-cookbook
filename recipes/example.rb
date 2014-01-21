container 'lucid' do
  options( template: 'ubuntu', template_options: ['-r lucid'])
  action [:create, :start]
end
