node.default["rvm"] ||= {}
node.default["rvm"]["rubies"] = {
  "ruby-1.9.3-p484" => { :command_line_options => "--verify-downloads 1" }
}

node.default["rvm"]["default_ruby"] = "ruby-1.9.3-p484"