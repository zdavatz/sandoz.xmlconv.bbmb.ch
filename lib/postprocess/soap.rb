#!/usr/bin/env ruby
# PostProcess::Soap -- xmlconv2 -- 25.08.2006 -- hwyss@ywesee.com

module XmlConv
  module PostProcess
    module Soap
      def Soap.update_partner(transaction)
        if((bdd = transaction.model) && (delivery = bdd.deliveries.first) \
           && (bsr = delivery.bsr) && (customer = bsr.customer))
          transaction.partner = customer.acc_id || customer.party_id
        end
      end
    end
  end
end
