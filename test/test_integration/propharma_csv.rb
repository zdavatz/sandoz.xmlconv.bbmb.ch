#!/usr/bin/env ruby
# Integration::TestProPharmaI2 -- xmlconv2 -- 17.09.2007 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'xmlconv/util/transaction'
require 'xmlconv/util/destination'
require 'conversion/propharma_bdd'
require 'conversion/bdd_csv'

module XmlConv
  module Integration
class TestProPharmaI2 < Test::Unit::TestCase
  def setup
    @target_dir = File.expand_path('data/propharma_csv',
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
  def test_propharma_csv
    XmlConv::CONFIG.default_filename = '%s%s_%s.txt'
    src = <<-EOS
[KUNDE]
idt=4100606423
nam=Heimstaette Baerau
ort=3552 Brau
[BSTELL]
ref=103492
dat=A80213
tim=1353
[ARTIK]
typ=P
phc=02839238
art=CARSOL CR TABL 200 MG 200 STK
mge=2
[ARTIK]
typ=P
phc=02839296
art=CARSOL CR TABL 400 MG 200 STK
mge=5
[ARTIK]
typ=P
phc=02550609
art=CITALOPRAM ECOSOL FILMTABL 40 MG 100 STK
mge=1
[ARTIK]
typ=P
phc=02940977
art=ECODOLOR RET TABL 100 MG 50 STK
mge=10
[ARTIK]
typ=P
phc=01301850
art=ECODUREX TABL 5/50 100 STK
mge=3
[ARTIK]
typ=P
phc=02128827
art=ECOFENAC LIPOGEL 1 % 100 G
mge=50
[ARTIK]
typ=P
phc=02128773
art=NORSOL TABL 400 MG 42 STK
mge=2
[ARTIK]
typ=P
phc=02919753
art=OMED TAB FILMTABL 20 MG 100 STK
mge=20
[ARTIK]
typ=P
phc=03463433
art=OMEPRAZOL SANDOZ ECO KAPS 40 MG 56 STK
mge=20
[ARTIK]
typ=P
phc=02965635
art=PRAVASTA ECO TABL 20 MG 100 STK
mge=3
[ARTIK]
typ=P
phc=02965730
art=TORASIS TABL 5 MG 100 STK
mge=10
[ARTIK]
typ=P
phc=03663623
art=METO ZEROK RET TABL 25 MG 100 STK
mge=1
    EOS
    ast = Conversion::ProPharmaBdd.parse(src)
    bdd = Conversion::ProPharmaBdd.convert(ast)
    csv_docs = Conversion::BddCsv.convert(bdd)
    assert_instance_of(Array, csv_docs)
    csv_doc = csv_docs.first
    assert_match(/^4100606423_.*\.txt/, csv_doc.filename)
    result = csv_doc.to_s.split("\n")
    dstr = Date.today.strftime("%d%m%Y")
    expected = <<-EOS
4100606423,,#{dstr},,02839238,,,2,,103492,
4100606423,,#{dstr},,02839296,,,5,,103492,
4100606423,,#{dstr},,02550609,,,1,,103492,
4100606423,,#{dstr},,02940977,,,10,,103492,
4100606423,,#{dstr},,01301850,,,3,,103492,
4100606423,,#{dstr},,02128827,,,50,,103492,
4100606423,,#{dstr},,02128773,,,2,,103492,
4100606423,,#{dstr},,02919753,,,20,,103492,
4100606423,,#{dstr},,03463433,,,20,,103492,
4100606423,,#{dstr},,02965635,,,3,,103492,
4100606423,,#{dstr},,02965730,,,10,,103492,
4100606423,,#{dstr},,03663623,,,1,,103492,
    EOS
    expected.split("\n").each_with_index { |line, index|
      assert_equal(line, result[index])
    }
  end
end
  end
end
