#!/usr/bin/env ruby
# TestPharmaciePlusBdd -- xmlconv2 -- 18.08.2006 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/pharmacieplus_bdd'


module XmlConv
	module Conversion
		class TestGehBdd < Test::Unit::TestCase
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
      <other-name> </other-name>
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
			end
			def test_parse
				document = PharmaciePlusBdd.parse(@src)
				assert_instance_of(REXML::Document, document)
			end
			def test_convert
				bdd = PharmaciePlusBdd.convert(@xml_doc)
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
        expected = "Pharmacie du Mandement"
        assert_equal(expected, name.to_s)
        address = shipto.address
        assert_instance_of(Model::Address, address)
        assert_equal(["3e adresse e-mail"], address.lines)
        assert_equal("1242", address.zip_code)
        assert_equal("Satigny", address.city)
        assert_equal(7, delivery.items.size)

        item = delivery.items.first
        assert_instance_of(Model::DeliveryItem, item)
        assert_equal('1', item.line_no)
        assert_equal('7680543801949', item.customer_id)
        assert_equal('2054098', item.pharmacode_id)
        assert_equal('15', item.qty)

				#bsr = delivery.bsr
				#assert_instance_of(Model::Bsr, bsr)

        ## second delivery:
        delivery = bdd.deliveries.last
				assert_instance_of(Model::Delivery, delivery)
        assert_equal('1861', delivery.customer_id)
        assert_equal('7601001368491', delivery.bsr_id)
        customer = delivery.customer
        assert_instance_of(Model::Party, customer)
        name = customer.name
        assert_instance_of(Model::Name, name)
        expected = "Pharm. Ecole-de-Médecine"
        assert_equal(expected, name.to_s)
			end
    end
  end
end
