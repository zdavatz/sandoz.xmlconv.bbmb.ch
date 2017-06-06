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

require 'xmlconv/config'

[ File.join(Dir.pwd, 'etc', 'xmlconv.yml'),
].each do |config_file|
  if File.exist?(config_file)
    puts "load from #{config_file}"
    XmlConv::CONFIG.load(config_file)
    break
  end
end
ENV['SERVER_PORT'] =  XmlConv::CONFIG.server_port.to_s if XmlConv::CONFIG.respond_to?(:server_port)

require 'rack'
require 'rack/static'
require 'rack/show_exceptions'
require 'rack'
require 'sbsm/logger'
require 'webrick'

require 'xmlconv/util/destination'
require 'xmlconv/util/transaction'
require 'xmlconv/util/application'
require 'xmlconv/util/rack_interface'

ENV['DRB_SERVER'] = 'druby://localhost:12004'
ENV['ACCESS_DESTINATION'] = '/var/www/sandoz.xmlconv.bbmb.ch/var/output/'
ENV['ACCESS_BBMB'] = 'druby://localhost:12004'
ENV['WRITER'] = 'BddCsv'

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
