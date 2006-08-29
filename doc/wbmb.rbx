#!/usr/bin/env ruby
# wbmb.rbx -- xmlconv2 -- 07.06.2004 -- hwyss@ywesee.com

$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'drb/drb'
require 'xmlconv/util/destination'
require 'xmlconv/util/transaction'

begin
	request = Apache.request
	connection = request.connection

	request.server.log_notice("Received Request #{request.request_method}")
	if(request.request_method != 'POST')
		request.status = 405 # Method not allowed
		exit
	end
	request.server.log_notice("from #{connection.remote_ip}")

	content_length = request.headers_in['Content-Length'].to_i
	request.server.log_notice("content-length: #{content_length}")
	if(content_length <= 0)
		request.status = 500 # Server Error
		request.server.log_error("zero length input")
		exit
	end

	xml_src = $stdin.read(content_length)

	DRb.start_service
	xmlconv = DRbObject.new(nil, ENV['DRB_SERVER'])
	destination = XmlConv::Util::Destination.book(ENV['ACCESS_GLOBOPHARM'])

	transaction = XmlConv::Util::Transaction.new
  transaction.domain = ENV['HTTP_HOST']
	transaction.input = xml_src
	transaction.reader = 'WbmbBdd'
	transaction.writer = 'BddI2'
	transaction.destination = destination
	transaction.origin = "http://#{connection.remote_ip}:#{connection.remote_port}"
  transaction.partner = 'SOAP'
  transaction.postprocs.push(['Soap', 'update_partner'])
  transaction.postprocs.push(['Bbmb', 'inject', ENV['ACCESS_BBMB'], 
                              'gag', '221200'])

	xmlconv.dispatch(transaction)

rescue StandardError => err
	request.server.log_error(err.class.to_s)
	request.server.log_error(err.message)
	request.server.log_error(err.backtrace.join("\n"))
	request.status = 500
ensure
	request.send_http_header
end
