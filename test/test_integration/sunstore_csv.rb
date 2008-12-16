#!/usr/bin/env ruby
# TestPharmaciePlusI2 -- xmlconv2 -- 21.08.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/transaction'
require 'xmlconv/util/destination'
require 'conversion/sunstore_bdd'
require 'conversion/bdd_csv'

module XmlConv
  module Integration
class TestXmlI2 < Test::Unit::TestCase
  def setup
    @src = <<-XML
<?xml version="1.0" encoding="ISO-8859-1"?>
<customerOrder xmlns="http://www.e-galexis.com/schemas/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.e-galexis.com/schemas/ http://www.e-galexis.com/schemas/POS/customerOrder/customerOrder.xsd"
  backLogDesired="true" compressionDesired="false" language="de"
  productDescriptionDesired="false" roundUpForCondition="true"
  version="1.0">
  <client number="test" password="test" />
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
    @target_dir = File.expand_path('data/pharmacieplus_csv',
      File.dirname(__FILE__))
    clear_dir
  end
  def teardown
    clear_dir
  end
  def clear_dir
    if(File.exist?(@target_dir))
      FileUtils.rm_r(@target_dir)
    end
  end
  def test_pharmacieplus_csv
    XmlConv::CONFIG.default_filename = "%s%s_%s.txt"
    bdd = Conversion::SunStoreBdd.convert(@xml_doc)
    csv_docs = Conversion::BddCsv.convert(bdd)
    assert_instance_of(Array, csv_docs)
    csv_doc = csv_docs.first
    assert_match(/^test_.*\.txt/, csv_doc.filename)
    result = csv_doc.to_s.split("\n")
    dstr = Date.today.strftime("%d%m%Y")
    expected = <<-EOS
,test,#{dstr},,1336630,,,10,,123ABCDE9012345,
,test,#{dstr},,,7680123456789,,5,,123ABCDE9012345,
    EOS
    expected.split("\n").each_with_index { |line, index|
      assert_equal(line, result[index])
    }
  end
end
  end
end
