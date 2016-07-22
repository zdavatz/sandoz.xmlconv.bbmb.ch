require 'pathname'

root_dir = Pathname.new(__FILE__).realpath.parent.parent
lib_dir  = root_dir.join('lib')
test_dir = root_dir.join('test')

$: << root_dir unless $:.include?(root_dir)
$: << lib_dir  unless $:.include?(lib_dir)
$: << test_dir unless $:.include?(test_dir)

require 'minitest/autorun'
require 'flexmock/minitest'

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }
