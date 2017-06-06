require 'test_helper'
require 'conversion/sunstore_bdd'
require 'xmlconv/util/transaction'

module XmlConv
  class SunStoreBddTest < ::Minitest::Test
    include TestingDataLoadable

    def setup
      @xml_src = load_testing_data('/conversion/sunstore-bdd.xml')
      @xml_doc = REXML::Document.new(@xml_src)
    end

    def test_parse
      document = Conversion::SunStoreBdd.parse(@xml_src)
      assert_instance_of(REXML::Document, document)
    end

    def test_convert
      bdd = Conversion::SunStoreBdd.convert(@xml_doc)
      assert_instance_of(Model::Bdd, bdd)
      assert_equal(1, bdd.deliveries.size)
      delivery = bdd.deliveries.first
      assert_instance_of(Model::Delivery, delivery)
      assert_equal('123ABCDE9012345', delivery.customer_id)
      bsr = delivery.bsr
      assert_instance_of(Model::Bsr, bsr)
      assert_equal('7601000755872', delivery.bsr_id)
      customer = delivery.customer
      assert_instance_of(Model::Party, customer)
      assert_equal('7601000755872', customer.acc_id)
      shipto = customer.ship_to
      assert_instance_of(Model::Party, shipto)
      name = shipto.name
      assert_instance_of(Model::Name, name)
      expected = 'Superkunde'
      assert_equal(expected, name.to_s)
      address = shipto.address
      assert_instance_of(Model::Address, address)
      assert_equal([ 'Dorfladen', 'Frau Muster',
                     'Linkestrasse 99' ],
                   address.lines)
      assert_equal('3322', address.zip_code)
      assert_equal('Schönbühl', address.city)
      assert_equal(2, delivery.items.size)

      item = delivery.items.first
      assert_instance_of(Model::DeliveryItem, item)
      assert_equal('1', item.line_no)
      assert_nil(item.et_nummer_id)
      assert_equal('1336630', item.pharmacode_id)
      assert_equal('10', item.qty)

      item = delivery.items.last
      assert_instance_of(Model::DeliveryItem, item)
      assert_equal('2', item.line_no)
      assert_equal('7680123456789', item.et_nummer_id)
      assert_nil(item.pharmacode_id)
      assert_equal('5', item.qty)
    end

    def test_respond_with_empty_response
      transaction = Util::Transaction.new
      transaction.instance_variable_set(
        :@model, Conversion::SunStoreBdd.convert(@xml_doc))

      response = Conversion::SunStoreBdd.respond(transaction, [])
      assert_instance_of(REXML::Document, response)

      output = ''
      REXML::Formatters::Pretty.new.write(response, output)
      expected_xml = load_testing_data(
        '/conversion/response/empty.xml').strip
      assert_equal(expected_xml, output)
    end

    def test_respond_with_order_response
      transaction = Util::Transaction.new
      transaction.instance_variable_set(
        :@model, Conversion::SunStoreBdd.convert(@xml_doc))

      response = Conversion::SunStoreBdd.respond(transaction, [
        order_id: '12345-1',
        products: []
      ])
      assert_instance_of(REXML::Document, response)

      output = ''
      REXML::Formatters::Pretty.new.write(response, output)
      expected_xml = load_testing_data(
        '/conversion/response/sunstore-bdd/order.xml').strip
      assert_equal(expected_xml, output)
    end

    def test_respond_with_order_and_products
      transaction = Util::Transaction.new
      transaction.instance_variable_set(
        :@model, Conversion::SunStoreBdd.convert(@xml_doc))

      response = Conversion::SunStoreBdd.respond(transaction, [
        order_id: '12345-1',
        products: [{
          description:    'Product & 1',
          article_number: '1'
        }, {
          description:    'Product & 2',
          article_number: '2'
        }]
      ])
      assert_instance_of(REXML::Document, response)

      output = ''
      REXML::Formatters::Pretty.new.write(response, output)
      expected_xml = load_testing_data(
        '/conversion/response/sunstore-bdd/order-and-products.xml').strip
      assert_equal(expected_xml, output)
    end
  end
end
