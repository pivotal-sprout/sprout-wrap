#!/usr/bin/env ruby
require 'erb'
require 'yaml'
require 'soloist/royal_crown'
require 'soloist/config'

## Monkey-patch Soloist::Config#run_chef() so it works with data bags
def run_chef
  exec(conditional_sudo("bash -c '#{chef_solo}'"))
end


royal_crown = Soloist::RoyalCrown.new(:path => 'soloistrc')
config = Soloist::Config.new( royal_crown )

puts config.recipes
puts config.log_level
puts config.cookbook_paths
puts royal_crown.node_json_path
