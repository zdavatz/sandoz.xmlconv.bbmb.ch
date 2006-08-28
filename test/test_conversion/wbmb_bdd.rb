#!/usr/bin/env ruby
# Conversion::TestWbmbBdd -- xmlconv2 -- 23.08.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/wbmb_bdd'
require 'soap/marshal'
require 'mock'
require 'flexmock'

module XmlConv
	module Conversion
		class TestWbmbBdd < Test::Unit::TestCase
      def setup
        @src = <<-XML
<?xml version="1.0" encoding="ISO-8859-1" ?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Body>
    <wbmb:auftrag xmlns:wbmb="http://ywesee.com/wbmb" xmlns:enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema">
      <wbmb:absender xsi:type="enc:Array" enc:arrayType="wbmb:identifier[3]">
        <wbmb:identifier>
          <wbmb:idtype>name</wbmb:idtype>
          <wbmb:idvalue>ywesee Testspitäler</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>kundennummer</wbmb:idtype>
          <wbmb:idvalue>99</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>auftragsnummer</wbmb:idtype>
          <wbmb:idvalue>10019</wbmb:idvalue>
        </wbmb:identifier>
      </wbmb:absender>
      <wbmb:empfaenger xsi:type="enc:Array" enc:arrayType="wbmb:identifier[2]">
        <wbmb:identifier>
          <wbmb:idtype>ean13</wbmb:idtype>
          <wbmb:idvalue>7601001000681</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>auftragsnummer</wbmb:idtype>
          <wbmb:idvalue>76</wbmb:idvalue>
        </wbmb:identifier>
      </wbmb:empfaenger>
      <wbmb:artikelliste xsi:type="enc:Array" enc:arrayType="wbmb:artikel[1]">
        <wbmb:artikel>
          <wbmb:position>1</wbmb:position>
          <wbmb:identifier>
            <wbmb:idtype>gag-code</wbmb:idtype>
            <wbmb:idvalue>300976</wbmb:idvalue>
          </wbmb:identifier>
          <wbmb:identifier>
            <wbmb:idtype>ean13</wbmb:idtype>
            <wbmb:idvalue>1234567890123</wbmb:idvalue>
          </wbmb:identifier>
          <wbmb:identifier>
            <wbmb:idtype>pharmacode</wbmb:idtype>
            <wbmb:idvalue>1234567</wbmb:idvalue>
          </wbmb:identifier>
          <wbmb:bestellmenge>12</wbmb:bestellmenge>
          <wbmb:artikelpreis>6.20</wbmb:artikelpreis>
        </wbmb:artikel>
      </wbmb:artikelliste>
      <wbmb:auftrag_info xsi:type="enc:Array" enc:arrayType="wbmb:info[4]">
        <wbmb:info>
          <wbmb:infotype>text</wbmb:infotype>
          <wbmb:infovalue>Diese Bestellung ist dringend!</wbmb:infovalue>
        </wbmb:info>
        <wbmb:info>
          <wbmb:infotype>lieferung_bis</wbmb:infotype>
          <wbmb:infovalue>2003-03-01 08:30:00</wbmb:infovalue>
        </wbmb:info>
        <wbmb:info>
          <wbmb:infotype>lieferadresse</wbmb:infotype>
          <wbmb:address xsi:type="enc:Array" enc:arrayType="wbmb:info[7]">
            <wbmb:info>
              <wbmb:infotype>name</wbmb:infotype>
              <wbmb:infovalue>ywesee</wbmb:infovalue>
            </wbmb:info>
            <wbmb:info>
              <wbmb:infotype>name</wbmb:infotype>
              <wbmb:infovalue>intellectual capital connected</wbmb:infovalue>
            </wbmb:info>
            <wbmb:info>
              <wbmb:infotype>strasse</wbmb:infotype>
              <wbmb:infovalue>Postfach 1234</wbmb:infovalue>
            </wbmb:info>
            <wbmb:info>
              <wbmb:infotype>strasse</wbmb:infotype>
              <wbmb:infovalue>Winterthurerstrasse 52</wbmb:infovalue>
            </wbmb:info>
            <wbmb:info>
              <wbmb:infotype>plz</wbmb:infotype>
              <wbmb:infovalue>8006</wbmb:infovalue>
            </wbmb:info>
            <wbmb:info>
              <wbmb:infotype>ort</wbmb:infotype>
              <wbmb:infovalue>Zuerich</wbmb:infovalue>
            </wbmb:info>
            <wbmb:info>
              <wbmb:infotype>land</wbmb:infotype>
              <wbmb:infovalue>Schweiz</wbmb:infovalue>
            </wbmb:info>
          </wbmb:address>
        </wbmb:info>
        <wbmb:info>
          <wbmb:infotype>versandkosten</wbmb:infotype>
          <wbmb:infovalue>12.34</wbmb:infovalue>
        </wbmb:info>
        <wbmb:info>
          <wbmb:infotype>schnittstelle</wbmb:infotype>
          <wbmb:infovalue>62</wbmb:infovalue>
        </wbmb:info>
      </wbmb:auftrag_info>
    </wbmb:auftrag>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
        XML
      end
      def test_convert
        bdd = WbmbBdd.convert(WbmbBdd.parse(@src))
        assert_instance_of(Model::Bdd, bdd)
        assert_equal(1, bdd.deliveries.size)
        delivery = bdd.deliveries.first
        customer = delivery.customer
        assert_instance_of(Model::Party, customer)
        assert_equal('ywesee Testspitäler', customer.name.to_s)
        assert_equal('99', delivery.bsr_id)
        assert_equal('10019', delivery.customer_id)
        seller = delivery.seller
        assert_equal('76', delivery.acc_id)
        assert_equal('7601001000681', seller.acc_id)
      end
      def test_parse
        auftrag = WbmbBdd.parse(@src)
        assert_respond_to(auftrag, :absender)
        absender = auftrag.absender
        assert_instance_of(Array, absender)
        assert_equal(3, absender.size)
        id = absender.first
        assert_equal('name', id.idtype)
        assert_equal(Iconv.iconv('utf8', 'latin1', 'ywesee Testspitäler').first,
                     id.idvalue)
      end
      def test_convert__robust
        src = <<-XML
<?xml version="1.0" encoding="ISO-8859-1" ?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Body>
    <wbmb:auftrag xmlns:wbmb="http://ywesee.com/wbmb" xmlns:enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema">
      <wbmb:absender xsi:type="enc:Array" enc:arrayType="wbmb:identifier[3]">
        <wbmb:identifier>
          <wbmb:idtype>name</wbmb:idtype>
          <wbmb:idvalue>ywesee Testspitäler</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>kundennummer</wbmb:idtype>
          <wbmb:idvalue>99</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>auftragsnummer</wbmb:idtype>
          <wbmb:idvalue>10019</wbmb:idvalue>
        </wbmb:identifier>
      </wbmb:absender>
      <wbmb:empfaenger xsi:type="enc:Array" enc:arrayType="wbmb:identifier[2]">
        <wbmb:identifier>
          <wbmb:idtype>ean13</wbmb:idtype>
          <wbmb:idvalue>7601001000681</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>auftragsnummer</wbmb:idtype>
          <wbmb:idvalue>76</wbmb:idvalue>
        </wbmb:identifier>
      </wbmb:empfaenger>
      <wbmb:artikelliste xsi:type="enc:Array" enc:arrayType="wbmb:artikel[1]">
        <wbmb:artikel>
          <wbmb:position>1</wbmb:position>
          <wbmb:identifier>
            <wbmb:idtype>gag-code</wbmb:idtype>
            <wbmb:idvalue>300976</wbmb:idvalue>
          </wbmb:identifier>
          <wbmb:identifier>
            <wbmb:idtype>ean13</wbmb:idtype>
            <wbmb:idvalue>1234567890123</wbmb:idvalue>
          </wbmb:identifier>
          <wbmb:identifier>
            <wbmb:idtype>pharmacode</wbmb:idtype>
            <wbmb:idvalue>1234567</wbmb:idvalue>
          </wbmb:identifier>
          <wbmb:bestellmenge>12</wbmb:bestellmenge>
        </wbmb:artikel>
      </wbmb:artikelliste>
    </wbmb:auftrag>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
        XML
        assert_nothing_raised { 
          WbmbBdd.convert(WbmbBdd.parse(src))
        }
      end
    end
  end
end
