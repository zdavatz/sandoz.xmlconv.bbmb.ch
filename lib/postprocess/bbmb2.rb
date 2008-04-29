#!/usr/bin/env ruby
# PostProcess::Bbmb2 -- xmlconv2 -- 25.08.2006 -- hwyss@ywesee.com

require 'drb'
require 'iconv'

module XmlConv
  module PostProcess
    module Bbmb2
      def Bbmb2.inject(drb_url, transaction)
        if(bdd = transaction.model)
          bbmb = DRbObject.new(nil, drb_url)
          messages = []
          bdd.deliveries.each { |delivery|
            inject_id, order, info = nil
            begin
              customer = delivery.customer
              inject_id = customer.acc_id
              inject_id ||= customer.ship_to.acc_id if customer.ship_to
              inject_id ||= customer.party_id
              order = order(delivery)
              info = info(delivery)
              bbmb.inject_order(inject_id, order, info, :deliver => true)
            rescue Exception => e
              message = "Bestellung OK, Eintrag in BBMB Fehlgeschlagen:\n" \
                << e.class.to_s << "\n" \
                << e.message << "\n\n" \
                << e.backtrace.join("\n") << "\n\n" \
                << "hospital: #{inject_id}\n"
              if(order)
                message << "\norder: \n"
                order.each { |k|  message << "#{k.inspect}\n" }
              end
              if(info)
                message << "\ninfo: \n"
                  info.each { |k,v| message << "#{k} => #{v}\n" }
              end
              messages.push message
            end
          }
          unless messages.empty?
            raise messages.join("\n\n")
          end
        end
      end
      def Bbmb2.item_ids(item)
        item.id_table.inject({}) { |memo, (domain, value)|
          key = case domain
                when 'et-nummer'
                  :ean13
                when 'pharmacode'
                  :pcode
                when 'lieferantenartikel'
                  :article_number
                end
          memo.store(key, value.gsub(/^0+/, ''))
          memo
        }
      end
      def Bbmb2.order(delivery)
        delivery.items.collect { |item|
          data = item_ids(item)
          data.store(:quantity, item.qty.to_i)
          data
        }
      end
      def Bbmb2.info(delivery)
        info = {
          :reference => iconv(delivery.customer_id),
        }
        lines = []
        if(text = delivery.free_text)
          lines.push text, ''
        end
        if((cust = delivery.customer) && ship = cust.ship_to)
          lines.push(ship.acc_id)
          lines.push(ship.name)
          if(addr = ship.address)
            lines.concat(addr.lines)
            lines.push([addr.zip_code, addr.city].compact.join(' '))
          end
        end
        lines.compact!
        info.store(:comment, iconv(lines.join("\n"))) unless lines.empty?
        info
      end
      def Bbmb2.iconv(str)
        @iconv ||= Iconv.new('utf8', 'latin1')
        @iconv.iconv str
      end
    end
  end
end
