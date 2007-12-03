#!/usr/bin/env ruby
# TestPharmaciePlusI2 -- xmlconv2 -- 21.08.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/transaction'
require 'xmlconv/util/destination'
require 'conversion/pharmacieplus_bdd'
require 'conversion/bdd_csv'

module XmlConv
  module Integration
class TestXmlI2 < Test::Unit::TestCase
  def setup
    @src = <<-XML
<?xml version="1.0" encoding="ISO-8859-1"?>
<commande id="1861" date="2006-08-16T09:32:35.303+02:00" xmlns="http://www.ofac.ch/XEDO">
<groupe>
<last-name>pharmacieplus Directe</last-name>
<first-name> </first-name>
<other-name>Messieurs Eric Bussat + Christian Rouvinez</other-name>
<address>
  <street>les courbes 5</street>
  <zip>1121</zip>
  <city>Bremblens</city>
</address>
<telecom>
  <phone number="021 811 48 88"/>
  <fax number="021 811 48 89"/>
</telecom>
<online>
  <email>secretariat@pharmacieplus.ch</email>
</online>
</groupe>
<fournisseur ean="7601001000681">
<last-name>GLOBOPHARM AG</last-name>
<first-name> </first-name>
<address>
  <street>Seestrasse 200</street>
  <zip>8700</zip>
  <city>KUESNACHT</city>
  <country>CH</country>
</address>
</fournisseur>
<com-global>
<article ean="7680543802083" pharmacode="2054106" qte-livraison="12" qte-facture="10">
  <desc>ANTRA MUPS 10 Tabl 10 mg 100 Stk</desc>
  <cond-com>
    <bonus facture="10" livre="12"/>
  </cond-com>
</article>
<article ean="7680543800386" pharmacode="2054081" qte-livraison="12" qte-facture="10">
  <desc>ANTRA MUPS 10 Tabl 10 mg 28 Stk</desc>
  <cond-com>
    <bonus facture="10" livre="12"/>
  </cond-com>
</article>
<article ean="7680543801949" pharmacode="2054098" qte-livraison="30" qte-facture="20">
  <desc>ANTRA MUPS 10 Tabl 10 mg 56 Stk</desc>
  <cond-com>
    <bonus facture="10" livre="15"/>
  </cond-com>
</article>
<article ean="7680543802403" pharmacode="2054158" qte-livraison="15" qte-facture="10">
  <desc>ANTRA MUPS 20 Tabl 20 mg 100 Stk</desc>
  <cond-com>
    <bonus facture="10" livre="15"/>
  </cond-com>
</article>
<article ean="7680543800898" pharmacode="2054129" qte-livraison="13" qte-facture="13">
  <desc>ANTRA MUPS 20 Tabl 20 mg 14 Stk</desc>
  <cond-com rabais="10.0"/>
</article>
<article ean="7680543800973" pharmacode="2054135" qte-livraison="28" qte-facture="20">
  <desc>ANTRA MUPS 20 Tabl 20 mg 28 Stk</desc>
  <cond-com>
    <bonus facture="10" livre="14"/>
  </cond-com>
</article>
<article ean="7680543802328" pharmacode="2054141" qte-livraison="17" qte-facture="17">
  <desc>ANTRA MUPS 20 Tabl 20 mg 56 Stk</desc>
  <cond-com rabais="15.0"/>
</article>
<article ean="7680543800706" pharmacode="2054112" qte-livraison="28" qte-facture="20">
  <desc>ANTRA MUPS 20 Tabl 20 mg 7 Stk</desc>
  <cond-com>
    <bonus facture="10" livre="14"/>
  </cond-com>
</article>
<article ean="7680548750532" pharmacode="2204899" qte-livraison="11" qte-facture="11">
  <desc>ATACAND PLUS Tabl 16/12.5 mg 28 Stk</desc>
  <cond-com rabais="5.0"/>
</article>
<article ean="7680548750617" pharmacode="2204907" qte-livraison="30" qte-facture="20">
  <desc>ATACAND PLUS Tabl 16/12.5 mg 98 Stk</desc>
  <cond-com>
    <bonus facture="10" livre="15"/>
  </cond-com>
</article>
</com-global>
<com-pharma ean="7601001368095">
<livraison>
  <last-name>Pharmacie du Mandement</last-name>
  <first-name> </first-name>
  <other-name> Madame Françoise Recipient </other-name>
  <address>
    <street>3e adresse e-mail</street>
    <zip>1242</zip>
    <city>Satigny</city>
  </address>
</livraison>
<article ean="7680543801949" pharmacode="2054098" qte-livraison="15" qte-facture="10">
  <desc>ANTRA MUPS 10 Tabl 10 mg 56 Stk</desc>
</article>
<article ean="7680543802403" pharmacode="2054158" qte-livraison="15" qte-facture="10">
  <desc>ANTRA MUPS 20 Tabl 20 mg 100 Stk</desc>
</article>
<article ean="7680543800898" pharmacode="2054129" qte-livraison="6" qte-facture="6">
  <desc>ANTRA MUPS 20 Tabl 20 mg 14 Stk</desc>
</article>
<article ean="7680543802328" pharmacode="2054141" qte-livraison="9" qte-facture="9">
  <desc>ANTRA MUPS 20 Tabl 20 mg 56 Stk</desc>
</article>
<article ean="7680543800706" pharmacode="2054112" qte-livraison="28" qte-facture="20">
  <desc>ANTRA MUPS 20 Tabl 20 mg 7 Stk</desc>
</article>
<article ean="7680548750532" pharmacode="2204899" qte-livraison="11" qte-facture="11">
  <desc>ATACAND PLUS Tabl 16/12.5 mg 28 Stk</desc>
</article>
<article ean="7680548750617" pharmacode="2204907" qte-livraison="30" qte-facture="20">
  <desc>ATACAND PLUS Tabl 16/12.5 mg 98 Stk</desc>
</article>
</com-pharma>
<com-pharma ean="7601001368491">
<livraison>
  <last-name>Pharm. Ecole-de-Médecine</last-name>
  <first-name> </first-name>
  <other-name> </other-name>
  <address>
    <street>3e adresse e-mail</street>
    <zip>1205</zip>
    <city>Genève</city>
  </address>
</livraison>
<article ean="7680543802083" pharmacode="2054106" qte-livraison="12" qte-facture="10">
  <desc>ANTRA MUPS 10 Tabl 10 mg 100 Stk</desc>
</article>
<article ean="7680543800386" pharmacode="2054081" qte-livraison="12" qte-facture="10">
  <desc>ANTRA MUPS 10 Tabl 10 mg 28 Stk</desc>
</article>
<article ean="7680543801949" pharmacode="2054098" qte-livraison="15" qte-facture="10">
  <desc>ANTRA MUPS 10 Tabl 10 mg 56 Stk</desc>
</article>
<article ean="7680543800898" pharmacode="2054129" qte-livraison="7" qte-facture="7">
  <desc>ANTRA MUPS 20 Tabl 20 mg 14 Stk</desc>
</article>
<article ean="7680543800973" pharmacode="2054135" qte-livraison="28" qte-facture="20">
  <desc>ANTRA MUPS 20 Tabl 20 mg 28 Stk</desc>
</article>
<article ean="7680543802328" pharmacode="2054141" qte-livraison="8" qte-facture="8">
  <desc>ANTRA MUPS 20 Tabl 20 mg 56 Stk</desc>
</article>
</com-pharma>
</commande>
    XML
    @xml_doc = REXML::Document.new(@src)
    @target_dir = File.expand_path('data/pharmacieplus_i2', 
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
    bdd = Conversion::PharmaciePlusBdd.convert(@xml_doc)
    csv_docs = Conversion::BddCsv.convert(bdd)
    assert_instance_of(Array, csv_docs)
    csv_doc = csv_docs.first
    assert_match(/^7601001368095_.*\.dat/, csv_doc.filename)
    result = csv_doc.to_s.split("\n")
    expected = <<-EOS
,7601001368095,03122007,,2054098,7680543801949,,15,,1861,
,7601001368095,03122007,,2054158,7680543802403,,15,,1861,
,7601001368095,03122007,,2054129,7680543800898,,6,,1861,
,7601001368095,03122007,,2054141,7680543802328,,9,,1861,
,7601001368095,03122007,,2054112,7680543800706,,28,,1861,
,7601001368095,03122007,,2204899,7680548750532,,11,,1861,
,7601001368095,03122007,,2204907,7680548750617,,30,,1861,
    EOS
    expected.split("\n").each_with_index { |line, index|
      assert_equal(line, result[index])
    }
  end
end
  end
end
