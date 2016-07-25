require 'rexml/document'

module XmlConv
  module Conversion
    class XmlParser
      # Parses xml input into bdd model object
      def self.parse(xml_src)
        REXML::Document.new(xml_src)
      end
    end
  end
end
