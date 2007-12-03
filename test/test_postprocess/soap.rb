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
        customer.should_receive(:acc_id)\
          .times(1).and_return { 'SOAPPartner' }
        bsr = FlexMock.new
        bsr.should_receive(:customer)\
          .times(1).and_return { customer }
        delivery = FlexMock.new
        delivery.should_receive(:bsr)\
          .times(1).and_return { bsr }
        model = FlexMock.new
        model.should_receive(:deliveries)\
          .times(1).and_return { [delivery] }
        transaction = FlexMock.new
        transaction.should_receive(:model)\
          .times(1).and_return { model }
        transaction.should_receive(:partner=, 1)\
          .times(1).and_return { |partner|
          assert_equal('SOAPPartner', partner)
        }
        Soap.update_partner(transaction)
      end
    end
  end
end
