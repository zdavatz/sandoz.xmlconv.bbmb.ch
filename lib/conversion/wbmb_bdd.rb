#!/usr/bin/env ruby
# Conversion::WbmbBdd -- xmlconv2 -- 23.08.2006 -- hwyss@ywesee.com

require 'soap/marshal'
require 'xmlconv/model/address'
require 'xmlconv/model/agreement'
require 'xmlconv/model/bdd'
require 'xmlconv/model/bsr'
require 'xmlconv/model/delivery'
require 'xmlconv/model/delivery_item'
require 'xmlconv/model/name'
require 'xmlconv/model/party'
require 'xmlconv/model/price'

module XmlConv
  module Conversion
    class WbmbBdd
class << self
  def convert(soap_mapping)
    bdd = Model::Bdd.new
    texted, normal = soap_mapping.artikelliste.partition { |article|
      article.respond_to?(:positionstext)
    }
    unless(normal.empty?)
      _bdd_add_xml_delivery(bdd, soap_mapping, normal)
    end
    unless(texted.empty?)
      _bdd_add_xml_delivery(bdd, soap_mapping, texted)
    end
    bdd
  end
  def parse(src)
    SOAP::Marshal.unmarshal(src)
  end
  def _bdd_add_xml_delivery(bdd, soap_mapping, positions)
    delivery = Model::Delivery.new
    if(soap_mapping.respond_to?(:absender))
      _delivery_add_sender_ids(delivery, soap_mapping.absender)
    end
    if(soap_mapping.respond_to?(:empfaenger))
      _delivery_add_recipient_ids(delivery, soap_mapping.empfaenger)
    end
    if(soap_mapping.respond_to?(:auftrag_info))
      _delivery_add_soap_info(delivery, soap_mapping.auftrag_info)
    end
    _delivery_add_soap_positions(delivery, positions)
    bdd.add_delivery(delivery)
  end
  def _delivery_add_sender_ids(delivery, ids)
    bsr = Model::Bsr.new
    customer = Model::Party.new
    customer.role = 'Customer'
    party = Model::Party.new
    party.role = 'Customer'
    ids.each { |id|
      value = _latin1(id.idvalue)
      case _latin1(id.idtype)
      when 'auftragsnummer'
        delivery.add_id('Customer', value)
      when 'ean13'
        party.add_id('ET-Nummer', value)
      when 'email'
        customer.add_id('email', value)
      when 'kundennummer'
        party.add_id('ACC', value)
        customer.add_id('ACC', value)
      when 'name'
        name = Model::Name.new
        name.text = value
        customer.name = name
      end
    }
    bill_to = Model::Party.new
    bill_to.role = 'BillTo'
    bill_to.add_id('ACC', '1075')
    customer.add_party(bill_to)
    delivery.add_party(customer)
    bsr.add_party(party)
    delivery.bsr = bsr
  end
  def _delivery_add_recipient_ids(delivery, ids)
    party = Model::Party.new
    party.role = 'Seller'
    ids.each { |id|
      key = case _latin1(id.idtype)
      when 'ean13'
        party.add_id('ACC', _latin1(id.idvalue))
      when 'auftragsnummer'
        delivery.add_id('ACC', _latin1(id.idvalue))
      end
    }
    if(party.acc_id.to_s.empty?)
      party.add_id("ACC", "7601001000681")
    end
    delivery.add_party(party) 
    party
  end
  def _delivery_add_soap_info(delivery, infos)
    infos.each { |info|
      case _latin1(info.infotype)
      when 'schnittstelle'
        delivery.bsr.interface = _latin1(info.infovalue)
      when 'lieferadresse'
        _party_add_delivery_address(delivery.customer, info)
      when 'lieferung_bis'
        delivery.delivery_date = begin
                                   DateTime.parse(_latin1(info.infovalue))
                                 rescue 
                                   DateTime.now
                                 end
      when 'text'
        text = Model::FreeText.new
        text << _latin1(info.infovalue)
        delivery.add_free_text('text', text)
      when 'versandkosten'
        delivery.transport_cost = _latin1(info.infovalue)
      end
    }
  end
  def _delivery_add_soap_positions(delivery, positions)
    positions.each_with_index { |pos, idx|
      item = Model::DeliveryItem.new
      item.line_no = idx.next.to_s
      _item_add_soap_ids(item, [pos.identifier].flatten)
      item.qty = _latin1(pos.bestellmenge)
      item.unit = 'PCE'
      if(amount = _named_value(pos, :artikelpreis))
        price = Model::Price.new
        price.purpose = 'NettoPreis'
        price.amount = amount
        item.add_price(price)
      end
      if(value = _named_value(pos, :positionstext))
        txt = Model::FreeText.new
        txt << _latin1(value)
        item.add_free_text('text', txt)
      end
      delivery.add_item(item)
    }
  end
  def _item_add_soap_ids(item, ids)
    ids.each { |id|
      key = _latin1(id.idtype)
      value = _latin1(id.idvalue)
      case key
      when 'ean13'
        item.add_id('ET-Nummer', value)
      when 'pcode'
        item.add_id('Pharmacode', value)
      when 'gag-code'
        item.add_id('LieferantenArtikel', value)
      else
        item.add_id(key, value)
      end
    }
  end
  def _named_value(parent, name)
    if(parent.respond_to?(name))
      _latin1(parent.send(name))
    end
  end
  def _party_add_delivery_address(party, info)
    shipto = Model::Party.new
    shipto.role = 'ShipTo'
    address = Model::Address.new
    names = []
    lines = []
    info.address.each { |part|
      value = _latin1(part.infovalue)
      case _latin1(part.infotype)
      when 'name'
        names.push(value)
      when 'strasse'
        lines.push(value)
      when 'plz'
        address.zip_code = value
      when 'ort'
        address.city = value
      when 'land'
        address.country = value
      end
    }
    name = Model::Name.new
    name.text = names.shift
    shipto.name = name
    names.concat(lines).each { |line| address.add_line(line) }
    shipto.address = address
    party.add_party(shipto)
  end
  def _latin1(txt)
    if(txt.is_a?(String))
      Iconv.iconv('latin1', 'utf8', txt).first
    end
  rescue
    txt
  end
end
    end
  end
end
