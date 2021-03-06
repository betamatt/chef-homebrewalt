
def load_current_resource
  @cask = Chef::Resource::HomebrewaltCask.new(new_resource.name)
  cask_dir = @cask.name

  Chef::Log.debug("Checking whether we've already installed cask #{new_resource.name}")
  if ::File.directory?("/opt/homebrew-cask/Caskroom/#{cask_dir}")
    @cask.casked true
  else
    @cask.casked false
  end
end

action :cask do
  unless @cask.casked
    execute "installing cask #{new_resource.name}" do
      user node['current_user']
      command "sudo -u #{node['current_user']} /usr/local/bin/brew cask install --appdir=/Applications #{new_resource.name}"
      not_if "sudo -u #{node['current_user']} /usr/local/bin/brew cask list | grep #{new_resource.name}"
    end
    new_resource.updated_by_last_action(true)
  end
end

action :uncask do
  if @cask.casked
    execute "uninstalling cask #{new_resource.name}" do
      user node['current_user']
      command "sudo -u #{node['current_user']} /usr/local/bin/brew cask uninstall #{new_resource.name}"
      only_if "sudo -u #{node['current_user']} /usr/local/bin/brew cask list | grep #{new_resource.name}"
    end
    new_resource.updated_by_last_action(true)
  end
end
