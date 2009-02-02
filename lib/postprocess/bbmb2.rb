#!/usr/bin/env ruby
# PostProcess::Bbmb2 -- xmlconv2 -- 25.08.2006 -- hwyss@ywesee.com

require 'drb'
require 'iconv'

module XmlConv
  module PostProcess
    module Bbmb2
      def Bbmb2.inject(drb_url, idtype, transaction=nil)
        if transaction.nil?
          transaction, idtype = idtype, nil
        end
        if(bdd = transaction.model)
          bbmb = DRbObject.new(nil, drb_url)
          messages = []
          bdd.deliveries.each_with_index { |delivery, idx|
            inject_id, order, info = nil
            begin
              customer = delivery.customer
              inject_id = customer.acc_id
              name = customer.name
              if ship = customer.ship_to
                name = ship.name
                if addr = ship.address
                  name = addr.lines.first
                end
                inject_id ||= ship_to.acc_id
              end
              inject_id ||= customer.party_id
              order = order(delivery)
              info = info(delivery)
              resp = bbmb.inject_order(inject_id, order, info, 
                                       :deliver => true,
                                       :create_missing_customer => idtype,
                                       :transaction => transaction.transaction_id,
                                       :customer_name => name)
              transaction.respond(idx, resp)
            rescue Exception => e
              transaction.respond(idx, :products => order)
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
          transaction.status = :bbmb_ok
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
          info.store(:comment, iconv(text))
        end
        info
      end
      def Bbmb2.iconv(str)
        @iconv ||= Iconv.new('utf8', 'latin1')
        @iconv.iconv str
      end
    end
  end
end
