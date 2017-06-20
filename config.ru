#\ -w -p 8011
# 8011 is the port used to serve
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
begin
  require 'pry'
rescue LoadError
end
lib_dir = File.expand_path(File.join(File.dirname(__FILE__), 'lib').untaint)
$LOAD_PATH << lib_dir
$stdout.sync = true

config_file =  File.join(Dir.pwd, 'etc', 'xmlconv.yml')

ARGV.push "config=#{config_file}"
raise "Configfile #{config_file} must exit" unless File.exist?(config_file)
puts "Use config_file #{config_file}"
require 'xmlconv/config'

XmlConv::CONFIG.load(config_file)
XmlConv::CONFIG.destination ||= File.join(Dir.pwd, 'var', 'output')
ENV['SERVER_PORT'] =  XmlConv::CONFIG.server_port.to_s if XmlConv::CONFIG.respond_to?(:server_port)
require 'bbmb/model/customer'
require 'bbmb/model/product'
require 'bbmb/model/order'
require 'bbmb/config'

require 'rack'
require 'rack/static'
require 'rack/show_exceptions'
require 'rack'
require 'sbsm/logger'
require 'webrick'

require 'xmlconv/version'
require 'xmlconv/util/destination'
require 'xmlconv/util/transaction'
require 'xmlconv/util/application'
require 'xmlconv/util/rack_interface'


SBSM.logger= ChronoLogger.new(XmlConv::CONFIG.log_pattern)
use Rack::CommonLogger, SBSM.logger
use(Rack::Static, urls: ["/doc/"])
use Rack::ContentLength
SBSM.info "Starting Rack::Server sandoz.xmlconv with log_pattern #{XmlConv::CONFIG.log_pattern}"

$stdout.sync = true
VERSION = `git rev-parse HEAD`
puts msg = "Used version: sbsm #{SBSM::VERSION}, XmlConv #{XmlConv::VERSION} sandoz.xmlconv #{VERSION}"
SBSM.logger.info(msg)
xml_conv_app = XmlConv.start_server
rack_interface = XmlConv::Util::RackInterface.new(app: xml_conv_app)
rack_app = Rack::ShowExceptions.new(Rack::Lint.new(rack_interface))
run rack_app
