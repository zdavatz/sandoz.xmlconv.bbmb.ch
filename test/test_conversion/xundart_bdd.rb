#!/usr/bin/env ruby
# TestPharmaciePlusBdd -- xmlconv2 -- 18.08.2006 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/xundart_bdd'

module XmlConv
	module Conversion
		class TestGehBdd < Test::Unit::TestCase
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
			end
			def test_parse
				document = XundartBdd.parse(@src)
				assert_instance_of(REXML::Document, document)
			end
			def test_convert
				bdd = XundartBdd.convert(@xml_doc)
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
        expected = "Dr. med. Xxxxx Xxxxxx"
        assert_equal(expected, name.to_s)
        address = shipto.address
        assert_instance_of(Model::Address, address)
        assert_equal(["Xxxxxxxxxxxxxxxxx 19"],
                     address.lines)
        assert_equal("9524", address.zip_code)
        assert_equal("Zuzwil", address.city)
        assert_equal(3, delivery.items.size)

        assert_equal 3, delivery.items.size
        item = delivery.items.first
        assert_instance_of(Model::DeliveryItem, item)
        assert_equal('1', item.line_no)
        assert_equal('7680568730217', item.et_nummer_id)
        assert_equal('3938385', item.pharmacode_id)
        assert_equal('19', item.qty)

				#bsr = delivery.bsr
				#assert_instance_of(Model::Bsr, bsr)

        ## last delivery:
        delivery = bdd.deliveries.last
				assert_instance_of(Model::Delivery, delivery)
        assert_equal('1234', delivery.customer_id)
        assert_equal('7601000000000', delivery.bsr_id)
        customer = delivery.customer
        assert_instance_of(Model::Party, customer)
        name = customer.name
        assert_instance_of(Model::Name, name)
        expected = "Max Muster"
        assert_equal(expected, name.to_s)
        expected = "St. Jakob-Strasse 56a"
        assert_equal(expected, customer.ship_to.address.lines.first)
			end
    end
  end
end
