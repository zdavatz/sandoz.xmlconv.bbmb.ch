#!/usr/bin/env ruby
# TestPharmaciePlusI2 -- xmlconv2 -- 21.08.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/transaction'
require 'xmlconv/util/destination'
require 'conversion/xundart_bdd'
require 'conversion/bdd_csv'

module XmlConv
  module Integration
class TestXmlI2 < Test::Unit::TestCase
  def setup
    @src = <<-XML
<?xml version="1.0" encoding="iso-8859-1"?>
<commande xmlns="http://www.xundart.ch" date="7/2/2009 5:29:52 PM" id="1234">
<com-pharma ean="7601010273543">
<livraison><last-name>Dr. med. Xxxxx Xxxxxx</last-name><address><street>Xxxxxxxxxxxxxxxxx 19</street><zip>9524</zip><city>Zuzwil</city></address></livraison>
<article ean="7680568730217" pharmacode="3938385" qte_facture="19"><desc>Torasemid Sandoz eco Tabl 2.5 mg 20 Stk</desc></article>
<article ean="7680569080175" pharmacode="3729807" qte_facture="2"><desc>Omeprazol Sandoz eco Filmtabl/Stechamp Filmtabl 20 mg 56 Stk</desc></article>
<article ean="7680162790136" pharmacode="0384673" qte_facture="3"><desc>Calcium Sandoz Ampullen 90 mg 10% 5x10 ml Ampullen</desc></article></com-pharma>

<com-pharma ean="7601010273963">
<livraison><last-name>Dr. med. Xxxxxxxxx Xxxxxxx</last-name><address><street>Xxxxxxxxxxxxx 3</street><zip>9602</zip><city>Bazenheid</city></address></livraison>
<article ean="7680560350208" pharmacode="3275944" qte_facture="3"><desc>Simcora Filmtabl 60 mg 100 Stk</desc></article></com-pharma>

<com-pharma ean="7601000000000">
<livraison><last-name> Max Muster</last-name><address><street>St. Jakob-Strasse 56a</street><zip>9000</zip><city>St. Gallen</city></address></livraison>
<article ean="7680562030047" pharmacode="3296509" qte_facture="5"><desc>Amoxicillin Sandoz Disp Tabl 1000 mg 20 Tabl</desc></article>
<article ean="7680162790136" pharmacode="0384673" qte_facture="1"><desc>Calcium Sandoz Ampullen 90 mg 10% 5x10 ml Ampullen</desc></article>
<article ean="7680562030184" pharmacode="3401484" qte_facture="10"><desc>Amoxicillin Sandoz Disp Tabl 750 mg 20 Tabl</desc></article></com-pharma>
</commande>
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
    bdd = Conversion::PharmaciePlusBdd.convert(@xml_doc)
    csv_docs = Conversion::BddCsv.convert(bdd)
    assert_instance_of(Array, csv_docs)
    csv_doc = csv_docs.first
    assert_match(/^7601010273543_.*\.txt/, csv_doc.filename)
    result = csv_doc.to_s.split("\n")
    dstr = Date.today.strftime("%d%m%Y")
    expected = <<-EOS
,7601010273543,#{dstr},,3938385,7680568730217,,"",,1234,
,7601010273543,#{dstr},,3729807,7680569080175,,"",,1234,
,7601010273543,#{dstr},,0384673,7680162790136,,"",,1234,
    EOS

    expected.split("\n").each_with_index { |line, index|
      assert_equal(line, result[index])
    }
  end
end
  end
end
