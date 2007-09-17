#!/usr/bin/env ruby
# Integration::TestProPharmaI2 -- xmlconv2 -- 17.09.2007 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/transaction'
require 'xmlconv/util/destination'
require 'conversion/propharma_bdd'
require 'conversion/bdd_i2'

module XmlConv
  module Integration
    class TestProPharmaI2 < Test::Unit::TestCase
      def setup
        @target_dir = File.expand_path('data/propharma_i2', 
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
      def test_propharma_i2
        src = <<-EOS
[KUNDE]
idt=123456
nam=Linden APOTHEKE
ort=5430 Wettingen
[BSTELL]
ref=100446
dat=070625
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
        ast = Conversion::ProPharmaBdd.parse(src)
				bdd = Conversion::ProPharmaBdd.convert(ast)
				i2_docs = Conversion::BddI2.convert(bdd)
        assert_instance_of(Array, i2_docs)
        assert_equal(1, i2_docs.size)
        i2_doc = i2_docs.first
        assert_equal("Linden_APOTHEKE_00100446.dat", i2_doc.filename)
				result = i2_doc.to_s.split("\n")
				expected = <<-EOS
001:7601001000681
002:ORDERX
003:220
010:#{i2_doc.filename}
100:YWESEE
101:100446
201:CU
202:123456
237:61
238:1
250:ADE
251:100446
300:4
301:#{Date.today.strftime('%Y%m%d')}
500:1
501:
502:02201228
520:1
521:PCE
500:2
501:
502:00931796
520:4
521:PCE
				EOS
				expected.split("\n").each_with_index { |line, index|
					assert_equal(line, result[index])
				}
			end
    end
  end
end
