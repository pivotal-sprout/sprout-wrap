define :rvm_ruby_install do
  ruby_version = params[:version] || params[:name]
  options = params[:options]
  raise "options should be a hash with :env and :command_line_options keys" unless options.is_a?(Hash)

  include_recipe "rvm::rvm"

  execute "clean out the archive and src directories each time.  bad downloads cause problems with rvm" do
    only_if params[:only_if] if params[:only_if]
    not_if params[:not_if] || "test -e #{::RVM_HOME}/bin/#{ruby_version}"
    command "rm -rf #{::RVM_HOME}/archives/*#{ruby_version}* #{::RVM_HOME}/src/*#{ruby_version}*"
    user params[:user] || node['current_user']
  end

  install_cmd = "#{options[:env]} #{RVM_COMMAND} install #{ruby_version} #{options[:command_line_options]}"
  
  execute "installing #{ruby_version} with RVM: #{install_cmd}" do
    only_if params[:only_if] if params[:only_if]
    not_if params[:not_if] || "test -e #{::RVM_HOME}/bin/#{ruby_version}"
    command install_cmd
    ignore_failure true
    user params[:user] || node['current_user']
  end

  execute "check #{ruby_version}" do
    command "#{RVM_COMMAND} list | grep #{ruby_version}"
    user params[:user] || node['current_user']
  end
end
