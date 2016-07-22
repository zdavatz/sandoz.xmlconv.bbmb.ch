require 'test_helper'
require 'conversion/wbmb_bdd'
require 'soap/marshal'

module XmlConv
  class WbmbBddTest < Minitest::Test
    include TestingDataLoadable

    def test_convert
      xml_src = load_testing_data('/conversion/wbmb-bdd.xml')
      bdd = Conversion::WbmbBdd.convert(Conversion::WbmbBdd.parse(xml_src))
      assert_instance_of(Model::Bdd, bdd)
      assert_equal(1, bdd.deliveries.size)
      delivery = bdd.deliveries.first
      customer = delivery.customer
      assert_instance_of(Model::Party, customer)
      assert_equal('ywesee Testspitäler', customer.name.to_s)
      assert_equal('99', customer.acc_id)
      assert_equal('10019', delivery.customer_id)
      seller = delivery.seller
      assert_equal('76', delivery.acc_id)
      assert_equal('7601001000681', seller.acc_id)
      assert_equal(1, delivery.items.size)
      assert_equal('Diese Bestellung ist dringend!', delivery.free_text)
    end

    def test_parse
      xml_src = load_testing_data('/conversion/wbmb-bdd.xml')
      auftrag = Conversion::WbmbBdd.parse(xml_src)
      assert_respond_to(auftrag, :absender)
      absender = auftrag.absender
      assert_instance_of(Array, absender)
      assert_equal(3, absender.size)
      id = absender.first
      assert_equal('name', id.idtype)
      assert_equal('ywesee Testspitäler', id.idvalue)
    end

    def test_convert__robust
      xml_src = load_testing_data('/conversion/wbmb-bdd-without-gag.xml')
      bdd = Conversion::WbmbBdd.convert(Conversion::WbmbBdd.parse(xml_src))
      assert_instance_of(Model::Bdd, bdd)
    end
  end
end
