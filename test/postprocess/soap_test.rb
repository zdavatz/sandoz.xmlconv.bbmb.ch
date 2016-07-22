require 'test_helper'
require 'postprocess/soap'

module XmlConv
  class SoapTest < Minitest::Test
    def test_update_partner
      customer = FlexMock.new
      customer.should_receive(:acc_id).once.and_return('SOAPPartner')
      bsr = FlexMock.new
      bsr.should_receive(:customer).once.and_return(customer)
      delivery = FlexMock.new
      delivery.should_receive(:bsr).once.and_return(bsr)
      model = FlexMock.new
      model.should_receive(:deliveries).once.and_return([delivery])
      transaction = FlexMock.new
      transaction.should_receive(:model).once.and_return(model)
      transaction.should_receive(:partner=).with('SOAPPartner').once
      PostProcess::Soap.update_partner(transaction)
      assert_spy_called(transaction, :partner=, 'SOAPPartner')
    end
  end
end
