#!/usr/bin/env ruby
# Integration::TestWbmbI2 -- xmlconv2 -- 23.08.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/transaction'
require 'xmlconv/util/destination'
require 'conversion/wbmb_bdd'
require 'conversion/bdd_i2'

module XmlConv
  module Integration
    class TestWbmbI2 < Test::Unit::TestCase
      def setup
        @target_dir = File.expand_path('data/wbmb_i2', 
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
      def test_wbmb_i2
        src = <<-XML
<?xml version="1.0" encoding="ISO-8859-1" ?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Body>
    <wbmb:auftrag xmlns:wbmb="http://ywesee.com/wbmb" xmlns:enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema">
      <wbmb:absender xsi:type="enc:Array" enc:arrayType="wbmb:identifier[4]">
        <wbmb:identifier>
          <wbmb:idtype>name</wbmb:idtype>
          <wbmb:idvalue>ywesee Testspitäler</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>kundennummer</wbmb:idtype>
          <wbmb:idvalue>99</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>email</wbmb:idtype>
          <wbmb:idvalue>hwyss@ywesee.com</wbmb:idvalue>
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
      <wbmb:artikelliste xsi:type="enc:Array" enc:arrayType="wbmb:artikel[2]">
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
          <wbmb:bestellmenge>1</wbmb:bestellmenge>
          <wbmb:artikelpreis>6.20</wbmb:artikelpreis>
          <wbmb:positionstext>*Ein Stück bitte vorweg senden</wbmb:positionstext>
        </wbmb:artikel>
      </wbmb:artikelliste>
      <wbmb:auftrag_info xsi:type="enc:Array" enc:arrayType="wbmb:info[5]">
        <wbmb:info>
          <wbmb:infotype>text</wbmb:infotype>
          <wbmb:infovalue>Diese Bestellung ist dringend!</wbmb:infovalue>
        </wbmb:info>
        <wbmb:info>
          <wbmb:infotype>lieferung_bis</wbmb:infotype>
          <wbmb:infovalue>2103-03-01 08:30:00</wbmb:infovalue>
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
              <wbmb:infovalue>Zürich</wbmb:infovalue>
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
        auftrag = SOAP::Marshal.unmarshal(src)
				bdd = Conversion::WbmbBdd.convert(auftrag)
				i2_docs = Conversion::BddI2.convert(bdd)
        assert_instance_of(Array, i2_docs)
        assert_equal(2, i2_docs.size)
        i2_doc = i2_docs.first
        assert_match(/^ywesee_Testspitler_00010019\.dat/, i2_doc.filename)
				result = i2_doc.to_s.split("\n")
				expected = <<-EOS
001:7601001000681
002:ORDERX
003:220
010:#{i2_doc.filename}
100:YWESEE
101:10019
201:CU
202:99
201:BY
202:1075
201:DP
220:ywesee
221:intellectual capital connected
222:Postfach 1234
223:Zürich
225:8006
226:Winterthurerstrasse 52
231:hwyss@ywesee.com
236:Diese Bestellung ist dringend!
237:62
238:1
242:12.34
250:ADE
251:10019
300:4
301:#{Date.today.strftime('%Y%m%d')}
300:2
301:21030301
500:1
501:300976
502:1234567890123
502:1234567
520:12
521:PCE
604:6.20
				EOS
				expected.split("\n").each_with_index { |line, index|
					assert_equal(line, result[index])
				}
        i2_doc = i2_docs.last
        assert_match(/^ywesee_Testspitler_XPR_00010019\.dat/, i2_doc.filename)
				result = i2_doc.to_s.split("\n")
				expected = <<-EOS
001:7601001000681
002:ORDERX
003:220
010:#{i2_doc.filename}
100:YWESEE
101:10019
201:CU
202:99
201:BY
202:1075
201:DP
220:ywesee
221:intellectual capital connected
222:Postfach 1234
223:Zürich
225:8006
226:Winterthurerstrasse 52
231:hwyss@ywesee.com
236:Diese Bestellung ist dringend!
237:62
238:1
242:12.34
250:ADE
251:10019
300:4
301:#{Date.today.strftime('%Y%m%d')}
300:2
301:21030301
500:1
501:300976
502:1234567890123
502:1234567
520:1
521:PCE
604:6.20
605:RS
606:*Ein Stück bitte vorweg senden
				EOS
				expected.split("\n").each_with_index { |line, index|
					assert_equal(line, result[index])
				}
			end
      def test_robustness__1
        src = <<-XML
<?xml version="1.0" encoding="ISO-8859-1" ?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Body>
    <wbmb:auftrag xmlns:wbmb="http://ywesee.com/wbmb" xmlns:enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema">
      <wbmb:absender xsi:type="enc:Array" enc:arrayType="wbmb:identifier[4]">
        <wbmb:identifier>
          <wbmb:idtype>name</wbmb:idtype>
          <wbmb:idvalue></wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>kundennummer</wbmb:idtype>
          <wbmb:idvalue>99</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>email</wbmb:idtype>
          <wbmb:idvalue>hwyss@ywesee.com</wbmb:idvalue>
        </wbmb:identifier>
        <wbmb:identifier>
          <wbmb:idtype>auftragsnummer</wbmb:idtype>
          <wbmb:idvalue>10019</wbmb:idvalue>
        </wbmb:identifier>
      </wbmb:absender>
      <wbmb:empfaenger xsi:type="enc:Array" enc:arrayType="wbmb:identifier[1]">
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
            <wbmb:idvalue></wbmb:idvalue>
          </wbmb:identifier>
          <wbmb:bestellmenge>12</wbmb:bestellmenge>
          <wbmb:artikelpreis>6.20</wbmb:artikelpreis>
        </wbmb:artikel>
      </wbmb:artikelliste>
      <wbmb:auftrag_info xsi:type="enc:Array" enc:arrayType="wbmb:info[5]">
        <wbmb:info>
          <wbmb:infotype>text</wbmb:infotype>
          <wbmb:infovalue>Diese Bestellung ist dringend!</wbmb:infovalue>
        </wbmb:info>
        <wbmb:info>
          <wbmb:infotype>lieferung_bis</wbmb:infotype>
          <wbmb:infovalue>2103-03-01 08:30:00</wbmb:infovalue>
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
              <wbmb:infovalue>Zürich</wbmb:infovalue>
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
        auftrag = SOAP::Marshal.unmarshal(src)
				bdd = Conversion::WbmbBdd.convert(auftrag)
				i2_docs = Conversion::BddI2.convert(bdd)
        assert_instance_of(Array, i2_docs)
        assert_equal(1, i2_docs.size)
        i2_doc = i2_docs.first
        assert_match(/^ohne_namen_.*\.dat/, i2_doc.filename)
				result = i2_doc.to_s.split("\n")
				expected = <<-EOS
001:7601001000681
002:ORDERX
003:220
010:#{i2_doc.filename}
100:YWESEE
101:10019
201:CU
202:99
201:BY
202:1075
201:DP
220:ywesee
221:intellectual capital connected
222:Postfach 1234
223:Zürich
225:8006
226:Winterthurerstrasse 52
231:hwyss@ywesee.com
236:Diese Bestellung ist dringend!
237:62
238:1
242:12.34
250:ADE
251:10019
300:4
301:#{Date.today.strftime('%Y%m%d')}
300:2
301:21030301
500:1
501:
520:12
521:PCE
604:6.20
				EOS
				expected.split("\n").each_with_index { |line, index|
					assert_equal(line, result[index])
				}
			end
    end
  end
end
