require 'test_helper'
require 'conversion/pharmacieplus_bdd'

module XmlConv
  class PharmaciePlusBddTest < Minitest::Test
    include TestingDataLoadable

    def setup
      @xml_src = load_testing_data('/conversion/pharmacieplus-bdd.xml')
      @xml_doc = REXML::Document.new(@xml_src)
    end

    def test_parse
      document = Conversion::PharmaciePlusBdd.parse(@xml_src)
      assert_instance_of(REXML::Document, document)
    end

    def test_convert
      bdd = Conversion::PharmaciePlusBdd.convert(@xml_doc)
      assert_instance_of(Model::Bdd, bdd)
      assert_equal(2, bdd.deliveries.size)
      delivery = bdd.deliveries.first
      assert_instance_of(Model::Delivery, delivery)
      assert_equal('1861', delivery.customer_id)
      bsr = delivery.bsr
      assert_instance_of(Model::Bsr, bsr)
      assert_equal('7601001368095', delivery.bsr_id)
      customer = delivery.customer
      assert_instance_of(Model::Party, customer)
      shipto = customer.ship_to
      assert_instance_of(Model::Party, shipto)
      name = shipto.name
      assert_instance_of(Model::Name, name)
      assert_equal('Monsieur Frèdèric Recipient', name.to_s)
      address = shipto.address
      assert_instance_of(Model::Address, address)
      assert_equal(
        ['Pharmacie du Mandement', '3e adresse e-mail'], address.lines)
      assert_equal('1242', address.zip_code)
      assert_equal('Satigny', address.city)
      assert_equal(7, delivery.items.size)

      item = delivery.items.first
      assert_instance_of(Model::DeliveryItem, item)
      assert_equal('1', item.line_no)
      assert_equal('7680543801949', item.et_nummer_id)
      assert_equal('2054098', item.pharmacode_id)
      assert_equal('10', item.qty)

      # second delivery:
      delivery = bdd.deliveries.last
      assert_instance_of(Model::Delivery, delivery)
      assert_equal('1861', delivery.customer_id)
      assert_equal('7601001368491', delivery.bsr_id)
      customer = delivery.customer
      assert_instance_of(Model::Party, customer)
      name = customer.name
      assert_instance_of(Model::Name, name)
      assert_equal('Madame Françoise Recipient', name.to_s)
      assert_equal(
        'Pharm. Ecole-de-Mèdecine', customer.ship_to.address.lines.first)
    end
  end
end
