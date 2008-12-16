#!/usr/bin/env ruby
# TestSunStoreBdd -- xmlconv2 -- 18.08.2006 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/sunstore_bdd'

module XmlConv
  module Conversion
    class TestGehBdd < Test::Unit::TestCase
      def setup
        @src = <<-XML
<?xml version="1.0" encoding="ISO-8859-1"?>
<customerOrder xmlns="http://www.e-galexis.com/schemas/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.e-galexis.com/schemas/ http://www.e-galexis.com/schemas/POS/customerOrder/customerOrder.xsd"
  backLogDesired="true" compressionDesired="false" language="de"
  productDescriptionDesired="false" roundUpForCondition="true"
  version="1.0">
  <client number="7601000755872" password="test" />
  <orderHeader deliveryDate="2002-08-25"
    referenceNumber="123ABCDE9012345" mannerOfTransport="tour"
    urgent="false">
    <deliveryAddress line1="Superkunde" line4="Linkestrasse 99"
      line5PostalCode="3322" line5City="Sch&#246;nb&#252;hl">
      <addressLine2And3Text line2="Dorfladen" line3="Frau Muster" />
    </deliveryAddress>
  </orderHeader>
  <orderLines>
    <productOrderLine orderQuantity="10" roundUpForCondition="true"
      backLogDesired="false">
      <pharmaCode id="1336630" />
    </productOrderLine>
    <productLabelOrderLine defaultOrderQuantity="5">
      <EAN id="7680123456789" />
      <supplierProductNumber EANsupplierId="54321678091432"
        id="123.234-2" />
    </productLabelOrderLine>
  </orderLines>
</customerOrder>
        XML
        @xml_doc = REXML::Document.new(@src)
      end
      def test_parse
        document = SunStoreBdd.parse(@src)
        assert_instance_of(REXML::Document, document)
      end
      def test_convert
        bdd = SunStoreBdd.convert(@xml_doc)
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
        expected = "Superkunde"
        assert_equal(expected, name.to_s)
        address = shipto.address
        assert_instance_of(Model::Address, address)
        assert_equal([ "Dorfladen", "Frau Muster",
                       "Linkestrasse 99" ],
                     address.lines)
        assert_equal("3322", address.zip_code)
        assert_equal("Schönbühl", address.city)
        assert_equal(2, delivery.items.size)

        item = delivery.items.first
        assert_instance_of(Model::DeliveryItem, item)
        assert_equal('1', item.line_no)
        assert_equal(nil, item.et_nummer_id)
        assert_equal('1336630', item.pharmacode_id)
        assert_equal('10', item.qty)

        item = delivery.items.last
        assert_instance_of(Model::DeliveryItem, item)
        assert_equal('2', item.line_no)
        assert_equal('7680123456789', item.et_nummer_id)
        assert_equal(nil, item.pharmacode_id)
        assert_equal('5', item.qty)
      end
    end
  end
end
