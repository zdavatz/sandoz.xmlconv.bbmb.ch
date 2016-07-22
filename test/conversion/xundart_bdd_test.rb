require 'test_helper'
require 'conversion/xundart_bdd'

module XmlConv
  class XundartBddTest < Minitest::Test
    include TestingDataLoadable

    def setup
      @xml_src = load_testing_data('/conversion/xundart-bdd.xml')
    end

    def test_parse
      document = Conversion::XundartBdd.parse(@xml_src)
      assert_instance_of(REXML::Document, document)
    end

    def test_convert
      xml_doc = REXML::Document.new(@xml_src)
      bdd = Conversion::XundartBdd.convert(xml_doc)

      assert_instance_of(Model::Bdd, bdd)
      assert_equal(3, bdd.deliveries.size)
      delivery = bdd.deliveries.first
      assert_instance_of(Model::Delivery, delivery)
      assert_equal('1234', delivery.customer_id)

      bsr = delivery.bsr
      assert_instance_of(Model::Bsr, bsr)
      assert_equal('7601010273543', delivery.bsr_id)
      customer = delivery.customer
      assert_instance_of(Model::Party, customer)

      shipto = customer.ship_to
      assert_instance_of(Model::Party, shipto)
      name = shipto.name
      assert_instance_of(Model::Name, name)
      assert_equal('Dr. med. Xxxxx Xxxxxx', name.to_s)

      address = shipto.address
      assert_instance_of(Model::Address, address)
      assert_equal(['Xxxxxxxxxxxxxxxxx 19'], address.lines)
      assert_equal('9524', address.zip_code)
      assert_equal('Zuzwil', address.city)
      assert_equal(3, delivery.items.size)

      item = delivery.items.first
      assert_instance_of(Model::DeliveryItem, item)
      assert_equal('1', item.line_no)
      assert_equal('7680568730217', item.et_nummer_id)
      assert_equal('3938385', item.pharmacode_id)
      assert_equal('19', item.qty)

      # last delivery:
      delivery = bdd.deliveries.last
      assert_instance_of(Model::Delivery, delivery)
      assert_equal('1234', delivery.customer_id)
      assert_equal('7601000000000', delivery.bsr_id)
      customer = delivery.customer
      assert_instance_of(Model::Party, customer)
      name = customer.name
      assert_instance_of(Model::Name, name)
      assert_equal('Max Muster', name.to_s)
      assert_equal(
        'St. Jakob-Strasse 56a', customer.ship_to.address.lines.first)
    end
  end
end
