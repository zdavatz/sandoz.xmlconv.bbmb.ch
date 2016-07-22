require 'test_helper'
require 'postprocess/bbmb2'
require 'conversion/pharmacieplus_bdd'
require 'conversion/wbmb_bdd'

module XmlConv
  class Bbmb2Test < Minitest::Test
    include TestingDataLoadable

    def test_inject
      xml_src = testing_data_path(
        '/postprocess/bbmb2/pharmacie-plus-bdd.xml')
      xml_doc = REXML::Document.new(File.read(xml_src))
      bdd = Conversion::PharmaciePlusBdd.convert(xml_doc)
      transaction = FlexMock.new
      transaction.should_receive(:input).and_return('')
      transaction.should_receive(:model).and_return(bdd)
      transaction.should_receive(:transaction_id).and_return('1')
      transaction.should_receive(:status=).with(:bbmb_ok).once
      transaction.should_receive(:respond).and_return('')
      bbmb = FlexMock.new
      expected_ids = %w{7601001368095 7601001368491}
      expected_orders = [
        [
          {ean13: '7680543801949', pcode: '2054098', quantity: 10},
          {ean13: '7680543802403', pcode: '2054158', quantity: 10},
          {ean13: '7680543800898', pcode: '2054129', quantity:  6},
          {ean13: '7680543802328', pcode: '2054141', quantity:  9},
          {ean13: '7680543800706', pcode: '2054112', quantity: 20},
          {ean13: '7680548750532', pcode: '2204899', quantity: 11},
          {ean13: '7680548750617', pcode: '2204907', quantity: 20}
        ], [
          {ean13: '7680543802083', pcode: '2054106', quantity: 10},
          {ean13: '7680543800386', pcode: '2054081', quantity: 10},
          {ean13: '7680543801949', pcode: '2054098', quantity: 10},
          {ean13: '7680543800898', pcode: '2054129', quantity:  7},
          {ean13: '7680543800973', pcode: '2054135', quantity: 20},
          {ean13: '7680543802328', pcode: '2054141', quantity:  8}
        ]
      ]
      expected_infos = [
        {reference: '1861'},
        {reference: '1861'}
      ]
      bbmb.should_receive(:inject_order).twice.and_return { |id, order, info|
        assert_equal(expected_ids.shift, id)
        assert_equal(expected_orders.shift, order)
        assert_equal(expected_infos.shift, info)
      }
      svc = DRb.start_service('druby://localhost:0', bbmb)
      PostProcess::Bbmb2.inject(svc.uri, 'ean13', transaction)
    ensure
      svc.stop_service if svc
    end

    def test_inject__soap
      xml_src = testing_data_path(
        '/postprocess/bbmb2/wbmb-bdd.xml')
      soap = SOAP::Marshal.unmarshal(File.read(xml_src))
      bdd = Conversion::WbmbBdd.convert(soap)
      transaction = FlexMock.new
      transaction.should_receive(:model).and_return(bdd)
      transaction.should_receive(:input).and_return('')
      transaction.should_receive(:transaction_id).and_return('2')
      transaction.should_receive(:status=).with(:bbmb_ok).once
      transaction.should_receive(:respond).and_return('')
      bbmb = FlexMock.new
      expected_orders = [[{
        ean13:          '1234567890123',
        pcode:          '1234567',
        quantity:       12,
        article_number: '300976'
      }]]
      expected_infos = [{
        reference: '10019',
        comment:   'äh... Diese Bestellung ist dringend!'
      }]
      bbmb.should_receive(:inject_order).once.and_return { |id, order, info|
        assert_equal('99', id)
        assert_equal(expected_orders.shift, order)
        assert_equal(expected_infos.shift, info)
      }
      svc = DRb.start_service('druby://localhost:0', bbmb)
      PostProcess::Bbmb2.inject(svc.uri, transaction)
    ensure
      svc.stop_service if svc
    end
  end
end
