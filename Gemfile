source 'https://rubygems.org'

gem 'xmlconv', '~> 1.0.9'
gem 'ydbi', '~> 0.5.3'
gem 'sbsm', '~> 1.3.0'
gem 'odba'
gem 'soap4r'

group :debugger do
  if RUBY_VERSION.match(/^1/)
    gem 'pry-debugger'
  else
    gem 'pry-byebug'
    gem 'pry-doc'
  end
end

group :test, :development do
  gem 'rake'
end

group :test do
  gem 'minitest', '~> 5.9'
  gem 'flexmock', '~> 2.2'

  gem 'rspec'
  gem 'watir'
  gem 'watir-webdriver'
end

group :development do
  gem 'yus'
end
