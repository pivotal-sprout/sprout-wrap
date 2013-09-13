# ruby
include_recipe "pivotal_workstation::rbenv"
include_recipe "pivotal_workstation::gem_setup"

# Libs
include_recipe "sprout-osx-apps::imagemagick"
include_recipe "sprout-osx-apps::node_js"
include_recipe "pivotal_workstation::qt"

# databases
include_recipe "pivotal_workstation::mysql"
include_recipe "pivotal_workstation::postgres"
include_recipe "pivotal_workstation::mongodb"
