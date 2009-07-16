#!/usr/bin/env ruby
# Conversion::XundartBdd -- xmlconv -- 16.07.2009 -- hwyss@ywesee.com

require 'conversion/pharmacieplus_bdd'

module XmlConv
  module Conversion
    class XundartBdd < PharmaciePlusBdd
class << self
  ## this is essentially the same format as PharmaciePlus - with the exception of
  #  what fields are used to transmit names. The PharmaciePlus converter needs to
  #  uncross last-name and pharmacy-name. The following two overriding methods
  #  remove this switch. From a design point-of view this is really the wrong way
  #  around (it would be better to have specialized behavior in the descendent
  #  class), but historically, and in terms of the
  #  "Xundart-is-a-PharmaciePlus-Format"-Relation, this seems the best way to
  #  do it.
  def _delivery_add_xml_customer(delivery, xml_delivery)
    customer = Model::Party.new
    customer.role = 'Customer'
    _customer_add_party(customer, '1075', 'BillTo')
    ship_to = _customer_add_party(customer,
                                  _latin1(xml_delivery.attributes['ean']),
                                  'ShipTo')
    if(xml_header = REXML::XPath.first(xml_delivery, 'livraison'))
      name = Model::Name.new
      # Pharmacieplus delivers the Pharmacy-Name in 'last-name', and the name
      # of the contact person in 'other-name' - we need to juggle the pieces
      # around a bit. (see also _party_add_xml_address)
      if(xml_name = REXML::XPath.first(xml_header, 'last-name'))
        name.last = _latin1(xml_name.text)
      end
      if(xml_name = REXML::XPath.first(xml_header, 'first-name'))
        name.first = _latin1(xml_name.text)
      end
      if(xml_name = REXML::XPath.first(xml_header, 'other-name'))
        name.text = _latin1(xml_name.text)
      end
      customer.name = name
      ship_to.name = name
      _party_add_xml_address(ship_to, xml_header)
    end
    if(xml_email = REXML::XPath.first(xml_delivery, '//groupe/online/email'))
      customer.add_id('email', _latin1(xml_email.text))
    end
    delivery.add_party(customer)
  end
  def _party_add_xml_address(party, xml_header)
    if(xml_address = REXML::XPath.first(xml_header, 'address'))
      address = Model::Address.new
      address.zip_code = _text(xml_address, 'zip')
      address.city = _text(xml_address, 'city')
      if(line = _text(xml_address, 'street'))
        address.add_line(line)
      end
      party.address = address
    end
  end
  ## this method adapts Xundart to the fact that the number of items is stored
  #  in the attribute qte_facture instead of qte-facture - for whatever reason...
  def _delivery_add_xml_item(delivery, xml_item)
    item = Model::DeliveryItem.new
    item.line_no = _latin1(delivery.items.size.next.to_s)
    item.add_id('ET-Nummer', _latin1(xml_item.attributes['ean']))
    item.add_id('Pharmacode', _latin1(xml_item.attributes['pharmacode']))
    item.qty = _latin1(xml_item.attributes['qte_facture'])
    item.unit = 'PCE'
    delivery.add_item(item)
  end
end
    end
  end
end
