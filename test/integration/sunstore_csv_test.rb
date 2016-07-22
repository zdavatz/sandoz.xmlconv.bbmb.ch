require 'test_helper'
require 'xmlconv/util/transaction'
require 'xmlconv/util/destination'
require 'conversion/sunstore_bdd'
require 'conversion/bdd_csv'

module XmlConv
  class TestXmlI2 < Minitest::Test
    include TestingDataLoadable

    def setup
      src = load_testing_data('/integration/sunstore.xml')
      @xml_doc = REXML::Document.new(src)
      @target_dir = File.expand_path(
        '../data/sunstore_csv', __FILE__)
      clear_dir
    end

    def teardown
      clear_dir
    end

    def test_pharmacieplus_csv
      XmlConv::CONFIG.default_filename = "%s%s_%s.txt"
      bdd = Conversion::SunStoreBdd.convert(@xml_doc)
      csv_docs = Conversion::BddCsv.convert(bdd)
      assert_instance_of(Array, csv_docs)
      csv_doc = csv_docs.first
      assert_match(/^test_.*\.txt/, csv_doc.filename)
      result = csv_doc.to_s.split("\n")
      dstr = Date.today.strftime("%d%m%Y")
      expected = <<~EOL
        ,test,#{dstr},,1336630,,,10,,123ABCDE9012345,""
        ,test,#{dstr},,,7680123456789,,5,,123ABCDE9012345,""
      EOL
      expected.split("\n").each_with_index { |line, index|
        assert_equal(line, result[index])
      }
    end

    private

    def clear_dir
      FileUtils.rm_r(@target_dir) if File.exist?(@target_dir)
    end
  end
end
