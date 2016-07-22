require 'test_helper'
require 'xmlconv/util/transaction'
require 'xmlconv/util/destination'
require 'conversion/pharmacieplus_bdd'
require 'conversion/bdd_csv'

module XmlConv
  class PharmaciePlusCsvTest < Minitest::Test
    include TestingDataLoadable

    def setup
      src = load_testing_data('/integration/pharmacieplus.xml')
      @xml_doc = REXML::Document.new(src)
      @target_dir = File.expand_path(
        '../data/pharmacieplus_csv', __FILE__)
      clear_dir
    end

    def teardown
      clear_dir
    end

    def test_pharmacieplus_csv
      CONFIG.default_filename = "%s%s_%s.txt"
      bdd = Conversion::PharmaciePlusBdd.convert(@xml_doc)
      csv_docs = Conversion::BddCsv.convert(bdd)
      assert_instance_of(Array, csv_docs)
      csv_doc = csv_docs.first
      assert_match(/^7601001368095_.*\.txt/, csv_doc.filename)
      result = csv_doc.to_s.split("\n")
      dstr = Date.today.strftime("%d%m%Y")
      expected = <<~EOL
        ,7601001368095,#{dstr},,2054098,7680543801949,,10,,1861,""
        ,7601001368095,#{dstr},,2054158,7680543802403,,10,,1861,""
        ,7601001368095,#{dstr},,2054129,7680543800898,,6,,1861,""
        ,7601001368095,#{dstr},,2054141,7680543802328,,9,,1861,""
        ,7601001368095,#{dstr},,2054112,7680543800706,,20,,1861,""
        ,7601001368095,#{dstr},,2204899,7680548750532,,11,,1861,""
        ,7601001368095,#{dstr},,2204907,7680548750617,,20,,1861,""
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
