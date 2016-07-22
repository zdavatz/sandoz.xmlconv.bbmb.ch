require 'xsd/charset'

module XSD
  module Charset
    @internal_encoding = 'NONE'
    #  class << self
    #    alias :orig_encoding_from_xml :encoding_from_xml
    #    def self.encoding_from_xml(str, charset)
    #      @internal_encoding = 'NONE'
    #      orig_encoding_from_xml(str, charset)
    #    end
    #  end
  end
end
