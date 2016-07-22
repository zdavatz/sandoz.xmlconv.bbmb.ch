lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rake/testtask'
require 'rake/clean'
require 'rspec/core/rake_task'


task :default => :test

task :spec => :clean
CLEAN.include FileList['pkg/*.gem']

# rspec
RSpec::Core::RakeTask.new(:spec)

# unit test
dir = File.dirname(__FILE__)
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = Dir.glob("#{dir}/test/**/*_test.rb")
  t.warning = false
  t.verbose = false
end
