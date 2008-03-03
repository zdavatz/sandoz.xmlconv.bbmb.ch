#!/usr/bin/env ruby
# Conversion::TestProPharmaBdd -- xmlconv2 -- 14.09.2007 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/propharma_bdd'
require 'flexmock'

module XmlConv
  module Conversion
    class TestWbmbBdd < Test::Unit::TestCase
      def setup
        @src = <<-EOS
[KUNDE]
idt=123456
nam=Linden APOTHEKE
ort=5430 Wettingen
[BSTELL]
ref=100446
dat=A70626
tim=2131
[ARTIK]
typ=P
phc=02201228
art=AVEENO ADULTS CREAM 100 ML
mge=1
[ARTIK]
typ=P
phc=00931796
art=MEPHAMESON 8 INJ LOES 8 MG 50 AMP 2 ML
mge=4
[ARTIK]
typ=P
phc=01995226
art=3M INDAIR TAPE HEISSLUFT 19MMX50M 12 STK
mge=19
[ARTIK]
typ=P
phc=02584519
art=ABRI NET NETZHOSE 130-190CM XXL ORANGE BTL 50 STK
mge=4
[ARTIK]
typ=P
phc=01901722
art=ASPIRIN CARDIO 300 TABL 300 MG 90 STK
mge=10
[ARTIK]
typ=P
phc=10001318
art=BLUTDRUCKMESSEN
mge=1
[ARTIK]
typ=P
phc=00829336
art=PONSTAN FILMTABS 500 MG 120 STK
mge=2
[ARTIK]
typ=P
phc=00703285
art=PONSTAN FILMTABS 500 MG 36 STK
mge=11
[ARTIK]
typ=P
phc=10001446
art=REZEPTEROEFFNUNG
mge=2
        EOS
      end
      def test_parse
        ast = ProPharmaBdd.parse(@src)
        assert_instance_of(SyntaxTree, ast)
      end
      def test_convert
        bdd = ProPharmaBdd.convert(ProPharmaBdd.parse(@src))
        assert_instance_of(Model::Bdd, bdd)
        assert_equal(1, bdd.deliveries.size)
        delivery = bdd.deliveries.first
        customer = delivery.customer
        assert_instance_of(Model::Party, customer)
        assert_equal("Linden APOTHEKE", customer.name.to_s)
        # customer_id is in reality the delivery_id assigned by the
        # customer - the slight confusion is due to automatic naming
        assert_equal('100446', delivery.customer_id)
        assert_equal('123456', delivery.bsr_id)
        customer = delivery.customer
        assert_equal('123456', customer.ids['customer'])
        seller = delivery.seller
        assert_equal('7601001000681', seller.acc_id)
        assert_equal(9, delivery.items.size)
        item = delivery.items.first
        assert_equal('02201228', item.pharmacode_id)
        assert_equal('1', item.qty)
        item = delivery.items.last
        assert_equal('10001446', item.pharmacode_id)
        assert_equal('2', item.qty)
      end
    end
  end
end
