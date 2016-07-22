require 'test_helper'
require 'postprocess/bbmb'
require 'conversion/pharmacieplus_bdd'

module XmlConv
  class BbmbTest < Minitest::Test
    include TestingDataLoadable

    def test_inject
      xml_src = load_testing_data(
        '/postprocess/bbmb/pharmacieplus-bdd.xml')
      xml_doc = REXML::Document.new(xml_src)
      bdd = Conversion::PharmaciePlusBdd.convert(xml_doc)
      transaction = FlexMock.new
      transaction.should_receive(:model).and_return(bdd)
      bbmb = FlexMock.new
      expected_orders = [[
        [{article_ean13: '7680543801949', article_pcode: '2054098'}, 15],
        [{article_ean13: '7680543802403', article_pcode: '2054158'}, 15],
        [{article_ean13: '7680543800898', article_pcode: '2054129'},  6],
        [{article_ean13: '7680543802328', article_pcode: '2054141'},  9],
        [{article_ean13: '7680543800706', article_pcode: '2054112'}, 28],
        [{article_ean13: '7680548750532', article_pcode: '2204899'}, 11],
        [{article_ean13: '7680548750617', article_pcode: '2204907'}, 30]
      ], [
        [{article_ean13: '7680543802083', article_pcode: '2054106'}, 12],
        [{article_ean13: '7680543800386', article_pcode: '2054081'}, 12],
        [{article_ean13: '7680543801949', article_pcode: '2054098'}, 15],
        [{article_ean13: '7680543800898', article_pcode: '2054129'},  7],
        [{article_ean13: '7680543800973', article_pcode: '2054135'}, 28],
        [{article_ean13: '7680543802328', article_pcode: '2054141'},  8]
      ]]
      expected_infos = [{
        order_reference: '1861',
        order_comment:   <<~EOC.strip
          7601001368095
          Monsieur Frèdèric Recipient
          Pharmacie du Mandement
          3e adresse e-mail
          1242 Satigny
          EOC
      }, {
        order_reference: '1861',
        order_comment:   <<~EOC.strip
          7601001368491
          Madame Françoise Recipient
          Pharm. Ecole-de-Mèdecine
          3e adresse e-mail
          1205 Genève
        EOC
      }]
      bbmb.should_receive(:inject_order).twice
        .and_return { |short, id, order, info|
        assert_equal('gag', short)
        assert_equal('221200', id)
        assert_equal(expected_orders.shift, order)
        assert_equal(expected_infos.shift, info)
        raise 'some error'
      }
      svc = DRb.start_service('druby://localhost:0', bbmb)
      assert_raises(RuntimeError) {
        PostProcess::Bbmb.inject(svc.uri, 'gag', '221200', transaction)
      }
    ensure
      svc.stop_service if svc
    end
  end
end
