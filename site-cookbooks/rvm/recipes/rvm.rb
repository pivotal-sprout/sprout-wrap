include_recipe "pivotal_workstation::git"

rvm_git_revision_hash  = version_string_for("rvm")

::RVM_HOME = "#{node['sprout']['home']}/.rvm"
::RVM_COMMAND = "#{::RVM_HOME}/bin/rvm"

sprout_osx_base_bash_it_enable_feature "plugins/rvm"

run_unless_marker_file_exists(marker_version_string_for("rvm")) do
  recursive_directories [RVM_HOME, 'src', 'rvm'] do
    owner node['current_user']
    recursive true
  end

  [
    "curl -sSL https://get.rvm.io | bash -s stable --autolibs=homebrew"
  ].each do |rvm_cmd|
    execute rvm_cmd do
      user node['current_user']
    end
  end

  %w{readline autoconf openssl zlib}.each do |rvm_pkg|
    execute "install rvm pkg: #{rvm_pkg}" do
      command "#{::RVM_COMMAND} pkg install --verify-downloads 1 #{rvm_pkg}"
      user node['current_user']
    end
  end
end

node["rvm"]["rubies"].each do |version, options|
  rvm_ruby_install version do
    options options
  end
end

execute "making #{node["rvm"]["default_ruby"]} with rvm the default" do
  not_if { node["rvm"]["default_ruby"].nil? }
  command "#{::RVM_COMMAND} alias create default #{node["rvm"]["default_ruby"]}"
  user node['current_user']
end
