#!/usr/bin/env ruby
# Conversion::ProPharmaBdd -- xmlconv2 -- 14.09.2007 -- hwyss@ywesee.com

require 'rockit/rockit'
require 'xmlconv/model/bdd'
require 'xmlconv/model/bsr'
require 'xmlconv/model/delivery'
require 'xmlconv/model/delivery_item'
require 'xmlconv/model/name'
require 'xmlconv/model/party'

module XmlConv
  module Conversion
    class ProPharmaBdd
@parser = Parse.generate_parser <<-EOG
Grammar ProPharma
  Tokens
    DATA = /[^\n]+/
    NL = /\n/
  Productions
    Bdd         -> Customer Order
    Customer    -> '[KUNDE]' NL CId CName Location
    CId         -> 'idt=' DATA NL
    CName       -> 'nam=' DATA NL
    Location    -> 'ort=' DATA NL
    Order       -> '[BSTELL]' NL Reference Date Time Item+
                   [: _, _, reference, date, time, items ]
    Reference   -> 'ref=' DATA NL
    Date        -> 'dat=' DATA NL
    Time        -> 'tim=' DATA NL
    Item        -> '[ARTIK]' NL Type PCode Description Quantity
    Type        -> 'typ=' DATA NL
    PCode       -> 'phc=' DATA NL
    Description -> 'art=' DATA NL
    Quantity    -> 'mge=' DATA NL
EOG
class << self
  def convert(ast)
    bdd = Model::Bdd.new
    delivery = _bdd_add_delivery(bdd, ast.order)
    _delivery_add_customer(delivery, ast.customer)
    bdd
  end
  def parse(src)
    @parser.parse(src) 
  end
  def _bdd_add_delivery(bdd, ast)
    delivery = Model::Delivery.new
    bsr = Model::Bsr.new
    delivery.add_id('Customer', _named_data(:reference, ast))
    _delivery_add_seller(delivery)
    delivery.bsr = bsr
    ast.items.each { |item|
      _delivery_add_item(delivery, item)
    }
    bdd.add_delivery(delivery)
    delivery
  end
  def _bsr_add_customer_id(bsr, id)
    customer = Model::Party.new
    customer.role = 'Customer'
    customer.add_id('ACC', id)
    bsr.add_party(customer)
  end
  def _delivery_add_customer(delivery, ast)
    _bsr_add_customer_id(delivery.bsr, _named_data(:cid, ast))
    customer = Model::Party.new
    customer.role = "Customer"
    customer.add_id('ACC', _named_data(:cid, ast))
    name = Model::Name.new
    name.text = _named_data(:cname, ast)
    customer.name = name
    delivery.add_party(customer)
    customer
  end
  def _delivery_add_item(delivery, ast)
    item = Model::DeliveryItem.new
    item.line_no = delivery.items.size.next.to_s
    item.add_id('Pharmacode', _named_data(:pcode, ast))
    item.qty = _named_data(:quantity, ast)
    item.unit = 'PCE'
    delivery.add_item(item)
  end
  def _delivery_add_seller(delivery)
    party = Model::Party.new
    party.role = 'Seller'
    party.add_id("ACC", "7601001000681")
    delivery.add_party(party)
  end
  def _named_data(key, ast)
    ast.send(key).data.value
  end
end
    end
  end
end
