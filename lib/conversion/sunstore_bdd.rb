#!/usr/bin/env ruby
# Conversion::SunStoreBdd -- xmlconv2 -- 12.12.2008 -- hwyss@ywesee.com

require 'rexml/document'
require 'xmlconv/model/bdd'

require 'xmlconv/model/address'
require 'xmlconv/model/bsr'
require 'xmlconv/model/delivery'
require 'xmlconv/model/delivery_item'
require 'xmlconv/model/name'
require 'xmlconv/model/party'


module XmlConv
  module Conversion
    class SunStoreBdd
class << self
  def convert(xml_document)
    bdd = Model::Bdd.new
    bsr = Model::Bsr.new
    _bsr_add_customer_id(bsr, 'YWESEESS')
    bdd.bsr = bsr
    REXML::XPath.each(xml_document, '//customerOrder') do |xml_delivery|
      _bdd_add_xml_delivery(bdd, xml_delivery)
    end
    bdd
  end
  def parse(xml_src)
    REXML::Document.new(xml_src)
  end
  def respond(transaction, responses)
    doc = REXML::Document.new <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<customerOrderResponse xmlns="http://www.e-galexis.com/schemas/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.e-galexis.com/schemas/ http://www.e-galexis.com/schemas/POS/customerOrder/customerOrderResponse.xsd"
  version="1.0" roundUpForCondition="false" backLogDesired="false"
  language="de" productDescriptionDesired="false">
</customerOrderResponse>
    EOS
    root = doc.root
    transaction.model.deliveries.each_with_index do |delivery, idx|
      if data = responses[idx]
        number = if(order_id = data[:order_id])
                   _utf8 order_id
                 else
                   "error-#{transaction.transaction_id}-#{idx}"
                 end
        root.add_element 'clientResponse', 'number' => number
        if data[:products].compact.size == delivery.items.size
          header = root.add_element 'orderHeaderResponse',
                                    'referenceNumber' => _utf8(delivery.customer_id)
          if ship_to = delivery.customer.ship_to
            attrs = { 'line1' => _utf8(ship_to.name) }
            attrs2 = {}
            if addr = ship_to.address
              addr.lines.each_with_index do |line, idx|
                line = _utf8 line
                case idx
                when 0
                  attrs2.store 'line2', line
                when 1
                  attrs2.store 'line3', line
                when 2
                  attrs.store 'line4', line
                end
              end
              attrs.store 'line5PostalCode', _utf8(addr.zip_code)
              attrs.store 'line5City', _utf8(addr.city)
            end
            address = header.add_element 'deliveryAddress', attrs
            unless attrs2.empty?
              address.add_element 'addressLine2And3Text', attrs2
            end
          end
          lines = root.add_element 'orderLinesResponse'
          delivery.items.each_with_index do |item, idx|
            presp = data[:products][idx]
            available = presp[:quantity] == presp[:deliverable]
            attrs = {
              'lineAccepted' => _boolean(available),
              'backLogLine'  => _boolean(presp[:backorder]),
              'roundUpForConditionDone' => 'false',
              'productReplaced' => 'false',
            }
            prod = lines.add_element 'productOrderLineResponse', attrs
            pol = prod.add_element 'productOrderLine',
                                   'orderQuantity' => presp[:quantity]
            if pcode = item.pharmacode_id
              pol.add_element 'pharmaCode', 'id' => pcode
            end
            if ean = item.et_nummer_id
              pol.add_element 'EAN', 'id' => ean
            end
            attrs = {
              'wholesalerProductCode' => presp[:article_number],
              'description' => presp[:description],
            }
            presp = prod.add_element 'productResponse', attrs
            prod.add_element 'availability',
                             'status' => available ? 'yes' : 'no'
          end
        else
          root.add_element 'orderHeaderErrorResponse'
        end
      else
        root.add_element 'clientErrorResponse'
      end
    end
    doc
  end
  def _bdd_add_xml_delivery(bdd, xml_delivery)
    delivery = Model::Delivery.new
    bsr = Model::Bsr.new
    xml_client = REXML::XPath.first(xml_delivery, 'client')
    _bsr_add_customer_id(bsr, xml_client.attributes['number'])
    delivery.bsr = bsr
    _delivery_add_xml_header(delivery, xml_delivery)
    if(xml_lines = REXML::XPath.first(xml_delivery, 'orderLines'))
      REXML::XPath.each(xml_lines,
                        'productOrderLine|productLabelOrderLine') do |xml_item|
        _delivery_add_xml_item(delivery, xml_item)
      end
    end
    bdd.add_delivery(delivery)
    delivery
  end
  def _boolean(item)
    item ? 'true' : 'false'
  end
  def _bsr_add_customer_id(bsr, id)
    customer = Model::Party.new
    customer.role = 'Customer'
    customer.add_id('ACC', id)
    bsr.add_party(customer)
  end
  def _customer_add_party(customer, id, role)
    party = Model::Party.new
    party.role = role
    party.add_id('ACC', id)
    customer.add_party(party)
    party
  end
  def _delivery_add_xml_customer(delivery, xml_delivery)
    customer = Model::Party.new
    customer.role = 'Customer'
    _customer_add_party(customer, '1075', 'BillTo')
    xml_client = REXML::XPath.first(xml_delivery, 'client')
    id = _latin1(xml_client.attributes['number'])
    customer.add_id('ACC', id)
    ship_to = _customer_add_party(customer, id, 'ShipTo')
    if(xml_header = REXML::XPath.first(xml_delivery, 'orderHeader'))
      name = Model::Name.new
      # The SunStore formant does not specify which part of the Delivery-Address
      # contains the customer's name. We're just guessing it might be in the first
      # line.
      if(xml_name = REXML::XPath.first(xml_header, 'deliveryAddress'))
        name.text = _latin1(xml_name.attributes['line1'])
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
  def _delivery_add_xml_header(delivery, xml_delivery)
    xml_order = REXML::XPath.first(xml_delivery, 'orderHeader')
    delivery.add_id('Customer', _latin1(xml_order.attributes['referenceNumber']))
    _delivery_add_xml_customer(delivery, xml_delivery)
  end
  def _delivery_add_xml_item(delivery, xml_item)
    item = Model::DeliveryItem.new
    item.line_no = _latin1(delivery.items.size.next.to_s)
    if(xml_pcode = REXML::XPath.first(xml_item, 'EAN'))
      item.add_id('ET-Nummer', _latin1(xml_pcode.attributes['id']))
    end
    if(xml_pcode = REXML::XPath.first(xml_item, 'pharmaCode'))
      item.add_id('Pharmacode', _latin1(xml_pcode.attributes['id']))
    end
    xml_qty = xml_item.attributes['orderQuantity'] \
      || xml_item.attributes['defaultOrderQuantity']
    item.qty = _latin1(xml_qty)
    item.unit = 'PCE'
    delivery.add_item(item)
  end
  def _party_add_xml_address(party, xml_header)
    if(xml_address = REXML::XPath.first(xml_header, 'deliveryAddress'))
      address = Model::Address.new
      address.zip_code = _latin1(xml_address.attributes['line5PostalCode'])
      address.city = _latin1(xml_address.attributes['line5City'])
      if(xml_lines = REXML::XPath.first(xml_address, 'addressLine2And3Text'))
        address.add_line(_latin1(xml_lines.attributes['line2']))
        address.add_line(_latin1(xml_lines.attributes['line3']))
      end
      if(line = xml_address.attributes['line4'])
        address.add_line(_latin1(line))
      end
      party.address = address
    end
  end
  def _latin1(str)
    Iconv.iconv('ISO-8859-1//TRANSLIT//IGNORE', 'UTF8', str).first.strip
  rescue
    str
  end
  def _utf8(str)
    Iconv.iconv('UTF-8//TRANSLIT//IGNORE', 'ISO-8859-1', str).first.strip
  rescue
    str
  end
end
    end
  end
end
