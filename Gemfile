source 'https://rubygems.org'

gem 'odba'
gem 'tmail'
gem 'xmlconv'
gem 'minitest'
gem 'flexmock'
group :debugger do
  if RUBY_VERSION.match(/^1/)
    gem 'pry-debugger'
  else
    gem 'pry-byebug'
    gem 'pry-doc'
  end
end

group :test do
  gem 'rspec'
  gem 'watir'
  gem 'watir-webdriver'
end

# NOTE: additional personal Gemfile.hack support for developer
#
# @example
#   bundle install         #=> loads Gemfile.hack, if it exists
#   HACK=no bundle install #=> ignores Gemfile.hack, even if it exists
group :development, :test do
  if ENV['HACK'] !~ /\A(no|false)\z/i
    hack = File.expand_path('../Gemfile.hack', __FILE__)
    if File.exist?(hack)
      eval File.read(hack)
    end
  end
end
