# This patch avoids loading issue by
# RuntimeError: XML processor module not found.
module XSD
  module XMLParser
    class << self
      alias :orig_constants :constants
      def constants
        orig_constants.map(&:to_s)
      end
    end
  end
end
