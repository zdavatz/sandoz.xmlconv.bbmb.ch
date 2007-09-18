#!/usr/bin/env ruby
# PostProcess::Bbmb -- xmlconv2 -- 25.08.2006 -- hwyss@ywesee.com

require 'drb'

module XmlConv
  module PostProcess
    module Bbmb
      def Bbmb.inject(drb_url, name_short, inject_id, transaction=nil)
        ## inject with 4 arguments is a special case where the recipient is 
        #  not known in BBMB. In all other cases we can take the inject_id
        #  directly from customer.acc_id. If so, inject is called with 
        #  3 arguments, with transaction as the third argument.
        if(transaction.nil?)
          transaction = inject_id
          inject_id = nil
        end
        if(bdd = transaction.model)
          bbmb = DRbObject.new(nil, drb_url)
          bdd.deliveries.each { |delivery|
            begin
              iid  = inject_id || delivery.customer.acc_id
              order = order(delivery)
              info = info(delivery)
              bbmb.inject_order(name_short, iid, order, info)
            rescue Exception => e
              message = "Bestellung OK, Eintrag in BBMB Fehlgeschlagen:\n" \
                << e.class.to_s << "\n" \
                << e.message << "\n\n" \
                << e.backtrace.join("\n") << "\n\n" \
                << "name_short: #{name_short}\n" \
                << "hospital: #{inject_id}\n"
              if(order)
                message << "\norder: \n"
                order.each { |k,v|  message << "#{k.inspect} => #{v}\n" }
              end
              if(info)
                message << "\ninfo: \n"
                  info.each { |k,v| message << "#{k} => #{v}\n" }
              end
              raise message
            end
          }
        end
      end
      def Bbmb.item_ids(item)
        item.id_table.inject({}) { |memo, (domain, value)|
          key = case domain
                when 'et-nummer'
                  :article_ean13
                when 'pharmacode'
                  :article_pcode
                when 'lieferantenartikel'
                  :article_number
                end
          memo.store(key, value)
          memo
        }
      end
      def Bbmb.order(delivery)
        pairs = []
        delivery.items.each { |item|
          pairs.push([item_ids(item), item.qty.to_i])
        }
        pairs
      end
      def Bbmb.info(delivery)
        info = {
          :order_reference => delivery.customer_id,
        }
        if(date = delivery.delivery_date)
          info.store(:order_expressdate, date)
        end
        lines = []
        if((cust = delivery.customer) && ship = cust.ship_to)
          lines.push(ship.acc_id)
          lines.push(ship.name)
          if(addr = ship.address)
            lines.concat(addr.lines)
            lines.push([addr.zip_code, addr.city].compact.join(' '))
          end
          info.store(:order_comment, lines.compact.join("\n"))
        end
        info
      end
    end
  end
end
