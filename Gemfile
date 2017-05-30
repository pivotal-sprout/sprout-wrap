source 'https://rubygems.org'

gem 'soloist', require: false

group :development do
  gem 'chefspec', '< 5.0.0', require: false # >=5.0.0 requires ruby v2.1
  gem 'foodcritic', '< 7.0.0', require: false # foodcritic >=7.0.0 drops support for ruby v2.0.0
  gem 'rspec', require: false
  gem 'rubocop', require: false
end

# Temporarily lock these gems. Newer versions depend on Ruby >= 2.1.0
# Remove this once https://github.com/mkocher/soloist/issues/39 is closed
gem 'chef', '~> 12.8.1', require: false
gem 'chef-zero', '~> 4.5.0', require: false
gem 'fauxhai', '< 3.7.0', require: false # >=3.7.0 requires ruby v2.1
gem 'ffi-yajl', '< 2.3.0', require: false # >=2.3.0 requires ruby v2.1
gem 'nokogiri', '< 1.7.0', require: false # >=1.7.0 requires ruby v2.1
gem 'ohai', '< 8.18.0', require: false # >=8.18.0 requires ruby v2.2.2
gem 'rack', '< 2.0.0', require: false # >=2.0.0 requires ruby v2.2.2
