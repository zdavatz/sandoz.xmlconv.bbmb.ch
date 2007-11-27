#!/usr/bin/env ruby
# PostProcess::TestBbmb2 -- xmlconv2 -- 25.08.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'postprocess/bbmb2'
require 'flexmock'
require 'conversion/pharmacieplus_bdd'
require 'conversion/propharma_bdd'
require 'conversion/wbmb_bdd'

module XmlConv
  module PostProcess
    class TestBbmb2 < Test::Unit::TestCase
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
        transaction.should_receive(:model).and_return { bdd }
        bbmb = FlexMock.new
        expected_ids = %w{7601001368095 7601001368491}
        expected_orders = [
          [
            { :ean13 => "7680543801949", :pcode => "2054098", :quantity => 15 },
            { :ean13 => "7680543802403", :pcode => "2054158", :quantity => 15 },
            { :ean13 => "7680543800898", :pcode => "2054129", :quantity => 6},
            { :ean13 => "7680543802328", :pcode=>"2054141", :quantity => 9},
            { :ean13 => "7680543800706", :pcode=>"2054112", :quantity => 28},
            { :ean13 => "7680548750532", :pcode=>"2204899", :quantity => 11},
            { :ean13 => "7680548750617", :pcode=>"2204907", :quantity => 30},
          ],
          [
            { :ean13 => "7680543802083", :pcode=>"2054106", :quantity => 12},
            { :ean13 => "7680543800386", :pcode=>"2054081", :quantity => 12},
            { :ean13 => "7680543801949", :pcode=>"2054098", :quantity => 15},
            { :ean13 => "7680543800898", :pcode=>"2054129", :quantity => 7},
            { :ean13 => "7680543800973", :pcode=>"2054135", :quantity => 28},
            { :ean13 => "7680543802328", :pcode=>"2054141", :quantity => 8},
          ],
        ]
        expected_infos = [
          {
            :reference  => "1861", 
            :comment    => <<-EOS.strip
7601001368095
Monsieur Frédéric Recipient
Pharmacie du Mandement
3e adresse e-mail
1242 Satigny
            EOS
          },
          {
            :reference  => "1861", 
            :comment    => <<-EOS.strip
7601001368491
Madame Françoise Recipient
Pharm. Ecole-de-Médecine
3e adresse e-mail
1205 Genève
            EOS
          },
        ]
        bbmb.should_receive(:inject_order).times(2)\
          .and_return { |id, order, info|
          assert_equal(expected_ids.shift, id)
          assert_equal(expected_orders.shift, order)
          assert_equal(expected_infos.shift, info)
        }
        svc = DRb.start_service('druby://localhost:0', bbmb)
        Bbmb2.inject(svc.uri, transaction)
      ensure
        svc.stop_service
      end 
      def test_inject__soap
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
        soap = SOAP::Marshal.unmarshal(src)
				bdd = Conversion::WbmbBdd.convert(soap)
        transaction = FlexMock.new
        transaction.should_receive(:model).and_return { bdd }
        bbmb = FlexMock.new
        expected_orders = [
          [
            { :ean13 => "1234567890123", :pcode => "1234567", 
              :quantity => 12, :article_number => "300976" },
          ],
        ]
        expected_infos = [
          {
            :reference => "10019",
            :comment => <<-EOS.strip
Diese Bestellung ist dringend!

ywesee
intellectual capital connected
Postfach 1234
Winterthurerstrasse 52
8006 Zuerich
            EOS
          },
        ]
        bbmb.should_receive(:inject_order).times(1)\
          .and_return { |id, order, info|
          assert_equal('99', id)
          assert_equal(expected_orders.shift, order)
          assert_equal(expected_infos.shift, info)
        }
        svc = DRb.start_service('druby://localhost:0', bbmb)
        Bbmb2.inject(svc.uri, transaction)
      #ensure
        #svc.stop_service
      end 
      def test_inject__propharma
        src = <<-EOS
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
        parsed = Conversion::ProPharmaBdd.parse(src)
				bdd = Conversion::ProPharmaBdd.convert(parsed)
        transaction = FlexMock.new
        transaction.should_receive(:model).and_return { bdd }
        bbmb = FlexMock.new
        expected_orders = [
          [
            {:pcode => "2201228", :quantity => 1},
            {:pcode => "931796", :quantity => 4},
            {:pcode => "1995226", :quantity => 19},
            {:pcode => "2584519", :quantity => 4},
            {:pcode => "1901722", :quantity => 10},
            {:pcode => "10001318", :quantity => 1},
            {:pcode => "829336", :quantity => 2},
            {:pcode => "703285", :quantity => 11},
            {:pcode => "10001446", :quantity => 2},
          ],
        ]
        expected_infos = [
          {
            :reference => "100446",
          },
        ]
        bbmb.should_receive(:inject_order).times(1)\
          .and_return { |id, order, info|
          assert_equal('123456', id)
          assert_equal(expected_orders.shift, order)
          assert_equal(expected_infos.shift, info)
        }
        svc = DRb.start_service('druby://localhost:0', bbmb)
        Bbmb2.inject(svc.uri, transaction)
      #ensure
        #svc.stop_service
      end 
    end
  end
end
