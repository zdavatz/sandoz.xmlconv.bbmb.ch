# This verbosing arround assignment fixes noise:
# `warning: variable $KCODE is no longer effective`
# at soap4r/lib/xsd/charset.rb:13
orig_verbose = $VERBOSE
$VERBOSE = nil
require 'xsd/charset'
$VERBOSE = orig_verbose

module XSD
  module Charset
    # This assignment means soap liberary does not convert
    # encoding (using iconv, it's for old ruby). We treats
    # encoding in application and xmlconv by ourself (using ruby's encoding)
    @internal_encoding = 'NONE'
  end
end
