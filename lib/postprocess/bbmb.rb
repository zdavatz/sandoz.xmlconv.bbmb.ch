#!/usr/bin/env ruby
# PostProcess::Bbmb -- xmlconv2 -- 25.08.2006 -- hwyss@ywesee.com

require 'drb'

module XmlConv
  module PostProcess
    module Bbmb
      def Bbmb.inject(drb_url, name_short, inject_id, transaction)
        if(bdd = transaction.model)
          begin
            bbmb = DRbObject.new(nil, drb_url)
            order = order(bdd)
            info = info(bdd)
            bbmb.inject_order(name_short, inject_id, order, info)
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
      def Bbmb.order(bdd)
        lookup = {}
        pairs = []
        bdd.deliveries.each { |delivery|
          delivery.items.each { |item|
            qty = item.qty.to_i
            ids = item_ids(item)
            if(existing_pair = pairs.find { |pair|
                 pair.first.any? { |key, value|
                   ids[key] == value
                 }
               })
              existing_pair[0].update(ids)
              existing_pair[1] += qty
            else
              pairs.push([ids, qty])
            end
          }
        }
        pairs
      end
      def Bbmb.info(bdd)
        pairs = {}
        references = []
        dates = []
        bdd.deliveries.each { |delivery|
          references.push(delivery.customer_id)
          dates.push(delivery.delivery_date)
        }
        ref_ids = references.compact.uniq.join('/')
        unless(ref_ids.empty?)
          pairs.store(:order_reference, ref_ids)
        end
        if(date = dates.compact.sort.first)
          pairs.store(:order_expressdate, date)
        end
        pairs
      end
    end
  end
end
