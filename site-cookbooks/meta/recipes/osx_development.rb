include_recipe "sprout-osx-apps::iterm2"
include_recipe "sprout-osx-base::homebrew"
include_recipe "sprout-osx-apps::virtualbox"
include_recipe "custom::btsync"

# GIT
include_recipe "pivotal_workstation::git_config_global_defaults"
include_recipe "pivotal_workstation::git_scripts"

execute "Setup git config" do
  command "git config --global user.name \"#{node['git']['name']}\""
  command "git config --global user.email \"#{node['git']['email']}\""
  user node['current_user']
end

include_recipe "sprout-osx-settings::global_environment_variables"
include_recipe "pivotal_workstation::unix_essentials"
include_recipe "pivotal_workstation::vim"
include_recipe "pivotal_workstation::vim_config"
