#!/usr/bin/env ruby
# PostProcess::TestBbmb -- xmlconv2 -- 25.08.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'postprocess/bbmb'
require 'flexmock'
require 'conversion/pharmacieplus_bdd'

module XmlConv
  module PostProcess
    class TestBbmb < Test::Unit::TestCase
      def test_inject
        src = <<-XML
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
      <other-name> Monsieur Frédéric Recipient </other-name>
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
      <other-name> Madame Françoise Recipient </other-name>
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
				xml_doc = REXML::Document.new(src)
				bdd = Conversion::PharmaciePlusBdd.convert(xml_doc)
        transaction = FlexMock.new
        transaction.mock_handle(:model) { bdd }
        bbmb = FlexMock.new
        expected_orders = [
          [
            [{:article_ean13=>"7680543801949", :article_pcode=>"2054098"}, 15],
            [{:article_ean13=>"7680543802403", :article_pcode=>"2054158"}, 15],
            [{:article_ean13=>"7680543800898", :article_pcode=>"2054129"}, 6],
            [{:article_ean13=>"7680543802328", :article_pcode=>"2054141"}, 9],
            [{:article_ean13=>"7680543800706", :article_pcode=>"2054112"}, 28],
            [{:article_ean13=>"7680548750532", :article_pcode=>"2204899"}, 11],
            [{:article_ean13=>"7680548750617", :article_pcode=>"2204907"}, 30],
          ],
          [
            [{:article_ean13=>"7680543802083", :article_pcode=>"2054106"}, 12],
            [{:article_ean13=>"7680543800386", :article_pcode=>"2054081"}, 12],
            [{:article_ean13=>"7680543801949", :article_pcode=>"2054098"}, 15],
            [{:article_ean13=>"7680543800898", :article_pcode=>"2054129"}, 7],
            [{:article_ean13=>"7680543800973", :article_pcode=>"2054135"}, 28],
            [{:article_ean13=>"7680543802328", :article_pcode=>"2054141"}, 8],
          ],
        ]
        expected_infos = [
          {
            :order_reference  => "1861", 
            :order_comment    => <<-EOS.strip
7601001368095
Monsieur Frédéric Recipient
Pharmacie du Mandement
3e adresse e-mail
1242 Satigny
            EOS
          },
          {
            :order_reference  => "1861", 
            :order_comment    => <<-EOS.strip
7601001368491
Madame Françoise Recipient
Pharm. Ecole-de-Médecine
3e adresse e-mail
1205 Genève
            EOS
          },
        ]
        bbmb.mock_handle(:inject_order, 2) { |short, id, order, info|
          assert_equal('gag', short)
          assert_equal('221200', id)
          assert_equal(expected_orders.shift, order)
          assert_equal(expected_infos.shift, info)
        }
        svc = DRb.start_service('druby://localhost:0', bbmb)
        Bbmb.inject(svc.uri, 'gag', '221200', transaction)
        bbmb.mock_verify
      ensure
        svc.stop_service
      end 
    end
  end
end
