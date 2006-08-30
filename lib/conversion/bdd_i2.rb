#!/usr/bin/env ruby
# BddI2 -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

require 'xmlconv/i2/document'
require 'xmlconv/i2/address'
require 'xmlconv/i2/position'

module XmlConv
  module Conversion
    class BddI2
      I2_ADDR_CODES = {
        'BillTo'    =>  :buyer,
        'Employee'  =>  :employee,
        'ShipTo'    =>  :delivery,
        'Customer'  =>  :customer,
      }
      I2_DELIVERY_CODES = {
        'wird abgeholt'   =>  :pickup,
        'werkslieferung'  =>  :delivery,
        'camion'          =>  :camion,
      }
      class << self
        def convert(bdd)
          sender_id = 'YWESEE'
          if((bsr = bdd.bsr) && (id = bsr.customer.acc_id))
            sender_id = id
          end
          bdd.deliveries.collect { |delivery|
            doc = I2::Document.new
            _doc_add_delivery(doc, delivery, sender_id)
            doc
          }
        end
        def _doc_add_delivery(doc, delivery, sender_id='YWESEE')
          order = I2::Order.new
          order.sender_id = sender_id
          # customer_id is in reality the delivery_id assigned by the
          # customer - the slight confusion is due to automatic naming
          transaction_id = delivery.customer_id
          order.ade_id = order.delivery_id = transaction_id
          doc.header.transaction_id = sprintf(transaction_id.to_s.rjust(8, '0'))
          order.add_date(I2::Date.from_date(::Date.today, :order, :order))
          if(bsr = delivery.bsr)
            order.interface = bsr.interface || '61'
            if(customer = bsr.customer)
              _order_add_party(order, customer)
            end
          end
          if(customer = delivery.customer)
            _order_add_customer(order, customer)
            prefix = customer.name.to_s
            prefix.gsub!(/\s+/, '_')
            prefix.gsub!(/[^a-z0-9_]/i, '')
            if(prefix.empty?)
              prefix = 'ohne_namen'
            end
            doc.header.prefix = prefix
            if(delivery.items.all? { |item| item.free_text })
              doc.header.suffix = 'XPR'
            end
            if(email = customer.ids['email'])
              order.agent = email
            end
          end
          if(seller = delivery.seller)
            doc.header.recipient_id = seller.acc_id
          end
          order.free_text = delivery.free_text
          if(date = delivery.delivery_date)
            order.add_date(I2::Date.from_date(date, :order, :delivery))
          end
          order.terms_cond = _express_status(delivery.delivery_date)
          order.transport_cost = delivery.transport_cost
          delivery.items.each { |item|
            _order_add_item(order, item)
          }
          doc.add_order(order)
        end
        def _address_add_bdd_addr(address, bdd_addr)
          if(bdd_addr.size < 2)
            bdd_addr.lines.each_with_index { |line, idx|
              address.send("street#{idx.next}=", line)
            }
          else
            ln1, ln2, ln3 = bdd_addr.lines
            address.name2 = ln1
            address.street1 = ln2
            address.street2 = ln3 
          end
          address.city = bdd_addr.city
          address.zip_code = bdd_addr.zip_code
        end
        def _express_status(time)
          #return '13' if express_override
          case time
          when DateTime
            date = Date.new(time.year, time.month, time.day)
            today = Date.today
            now = Time.now
            if(date < today)
              if((10...16).include?(now.hour)) # delivery following day before 9
                :before_9
              else # delivery (following day?) before 16
                :before_16
              end
            elsif(date == today)
              if(now.hour < 10)
                if(time.hour < 16) # delivery before 16
                  :before_16
                else # delivery before 21
                  :before_21
                end
              elsif(now.hour < 16) # delivery following day before 9
                :before_9
              else # delivery following day before 16
                :before_16
              end
            elsif(date == today.next)
              if(time.hour < 9) 
                if(now.hour < 16) # delivery following day before 9
                  :before_9
                else # delivery following day before 16
                  :before_16
                end
              end
            end
          end || :default
        end
        def _order_add_customer(order, customer)
          customer.parties.each { |party|
            _order_add_party(order, party)
          }
        end
        def _order_add_party(order, party)
          address = I2::Address.new
          address.party_id = party.acc_id
          if(name = party.name)
            address.name1 = name.to_s
          end
          if(code = I2_ADDR_CODES[party.role])
            address.code = code
          end
          if(bdd_addr = party.address)
            _address_add_bdd_addr(address, bdd_addr)
          end
          order.add_address(address)
        end
        def _order_add_item(order, item)
          position = I2::Position.new
          position.number = item.line_no
          ## switch ean13 and customer-ids, due to gag xmlconv/i2 convention
          position.customer_id = item.et_nummer_id
          position.article_ean = item.customer_id
          position.pharmacode = item.pharmacode_id
          position.qty = item.qty
          position.unit = item.unit
          if(date = item.delivery_date)
            position.delivery_date = I2::Date.from_date(date)
          end
          if(price = item.get_price('NettoPreis'))
            position.price = price.amount
          end
          position.free_text = item.free_text
          order.add_position(position)
        end
      end
    end
  end
end
