#!/usr/bin/env ruby
# PostProcess::TestSoap -- xmlconv2 -- 25.08.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'postprocess/soap'
require 'flexmock'

module XmlConv
  module PostProcess
    class TestSoap < Test::Unit::TestCase
      def test_update_partner
        customer = FlexMock.new
        customer.mock_handle(:acc_id) { 'SOAPPartner' }
        bsr = FlexMock.new
        bsr.mock_handle(:customer) { customer }
        delivery = FlexMock.new
        delivery.mock_handle(:bsr) { bsr }
        model = FlexMock.new
        model.mock_handle(:deliveries) { [delivery] }
        transaction = FlexMock.new
        transaction.mock_handle(:model) { model }
        transaction.mock_handle(:partner=, 1) { |partner|
          assert_equal('SOAPPartner', partner)
        }
        Soap.update_partner(transaction)
        transaction.mock_verify
      end
    end
  end
end
