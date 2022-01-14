source 'https://rubygems.org'

gem 'soloist', require: false

# >= 1.15.2 supports macOS 12.0 / Xcode 13.2
#  ffi clang M1 compile
gem 'ffi', '>= 1.15.2', require: false

gem 'plist', require: false

gem 'librarian-chef', require: false

# lyraphase-chef requires nokogiri gem
gem 'nokogiri', require: false

group :development do
  gem 'pry', require: false
  gem 'pry-coolline', require: false
  gem 'pry-byebug', require: false
  gem 'bundler', require: false
  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-shell', require: false

  # Upstream pivotal/sprout-wrap gems
  gem 'chefspec'
  gem 'foodcritic'
  gem 'rspec', require: false
  gem 'rubocop', require: false

  gem 'fauxhai', '~> 6.0.0', require: false # versions after 6.0.1 remove `node['etc']`
end

gem 'chef-zero', '~> 13.1', require: false # versions after 14.x require ruby 2.4
