#!/usr/bin/env ruby
# TestBddI2 -- xmlconv2 -- 02.06.2004 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'conversion/bdd_i2'
require 'flexmock'
require 'mock'

module XmlConv
	module Conversion
		class TestBddI2 < Test::Unit::TestCase
			def test_convert
        agreement = FlexMock.new
        agreement.should_receive(:terms_cond)\
          .times(1).and_return { 'camion' }
        bsr = FlexMock.new
        bsr.should_receive(:interface)\
          .times(1).and_return { }
        bsr.should_receive(:customer)\
          .times(1).and_return { }
				delivery = FlexMock.new
        delivery.should_receive(:bsr)\
          .times(1).and_return { bsr }
				delivery.should_receive(:bsr_id)\
          .times(1).and_return { 'BSR-ID' }
				delivery.should_receive(:customer_id)\
          .times(1).and_return { '1234' }
				delivery.should_receive(:customer)\
          .times(1).and_return {}
				delivery.should_receive(:seller)\
          .times(1).and_return {}
				delivery.should_receive(:free_text)\
          .times(1).and_return {}
				delivery.should_receive(:delivery_date)\
          .times(1).and_return {}
				delivery.should_receive(:transport_cost)\
          .times(1).and_return {}
				delivery.should_receive(:agreement)\
          .times(1).and_return { agreement }
				delivery.should_receive(:items)\
          .times(1).and_return { [] }
        customer = FlexMock.new
        customer.should_receive(:acc_id)\
          .times(1).and_return { 'YWESEEPP' }
        gbsr = FlexMock.new
        gbsr.should_receive(:customer)\
          .times(1).and_return { customer }
				bdd = FlexMock.new
				bdd.should_receive(:deliveries)\
          .times(1).and_return { [delivery] }
        bdd.should_receive(:bsr)\
          .times(1).and_return { gbsr }
				i2s = BddI2.convert(bdd)
        assert_instance_of(Array, i2s)
        i2 = i2s.first
				assert_instance_of(I2::Document, i2)
				header = i2.header
				assert_instance_of(I2::Header, header)
				assert_equal('EPIN_PL_00001234.dat', header.filename)
			end
			def test__doc_add_delivery
				doc = I2::Document.new
        agreement = FlexMock.new
        agreement.should_receive(:terms_cond)\
          .times(1).and_return { 'camion' }
				delivery = FlexMock.new
				delivery.should_receive(:customer_id)\
          .times(1).and_return { 'Customer-Delivery-Id' }
				delivery.should_receive(:bsr)\
          .times(1).and_return { }
				delivery.should_receive(:bsr_id)\
          .times(1).and_return { 'BSR-ID' }
				delivery.should_receive(:customer)\
          .times(1).and_return {}
				delivery.should_receive(:delivery_date)\
          .times(1).and_return {}
				delivery.should_receive(:transport_cost)\
          .times(1).and_return {}
				delivery.should_receive(:seller)\
          .times(1).and_return {}
				delivery.should_receive(:free_text)\
          .times(1).and_return {}
				delivery.should_receive(:agreement)\
          .times(1).and_return { agreement }
				delivery.should_receive(:items)\
          .times(1).and_return { [] }
				BddI2._doc_add_delivery(doc, delivery)
				order = doc.orders.first
				assert_equal('YWESEE', order.sender_id)
				assert_equal('Customer-Delivery-Id', order.delivery_id)
				assert_equal(:default, order.terms_cond)
			end
			def test__order_add_customer
				order = Mock.new('Order')
				customer = FlexMock.new('Customer')
				employee = FlexMock.new('Employee')
				bill_to = FlexMock.new('BillTo')
				ship_to = FlexMock.new('ShipTo')
				bill_addr = FlexMock.new('BillAddress')
				ship_addr = FlexMock.new('ShipAddress')
				customer.should_receive(:parties)\
          .times(1).and_return {
					[employee, ship_to, bill_to]
				}
				employee.should_receive(:acc_id)\
          .times(1).and_return { }
				employee.should_receive(:name)\
          .times(1).and_return { 'EmployeeName' }
				employee.should_receive(:role)\
          .times(1).and_return { 'Employee' }
				employee.should_receive(:address)\
          .times(1).and_return { }
				order.__next(:add_address) { |addr|
					assert_instance_of(I2::Address, addr)
					assert_equal(:employee, addr.code)
					assert_nil(addr.party_id)
					assert_equal('EmployeeName', addr.name1)
				}

				ship_to.should_receive(:acc_id)\
          .times(1).and_return { }
				ship_to.should_receive(:name)\
          .times(1).and_return { 'Name' }
				ship_to.should_receive(:role)\
          .times(1).and_return { 'ShipTo' }
				ship_to.should_receive(:address)\
          .times(1).and_return { ship_addr }
				ship_addr.should_receive(:size)\
          .times(1).and_return { 0 }
				ship_addr.should_receive(:lines)\
          .times(1).and_return { [] }
				ship_addr.should_receive(:city)\
          .times(1).and_return { 'City' } 
				ship_addr.should_receive(:zip_code)\
          .times(1).and_return { 'ZipCode' } 
				order.__next(:add_address) { |addr|
					assert_instance_of(I2::Address, addr)
					assert_equal(:delivery, addr.code)
					assert_equal('Name', addr.name1)
					assert_equal('City', addr.city)
					assert_equal('ZipCode', addr.zip_code)
				}

				bill_to.should_receive(:acc_id)\
          .times(1).and_return { 'BillToId' }
				bill_to.should_receive(:name)\
          .times(1).and_return { 'BillToName' }
				bill_to.should_receive(:role)\
          .times(1).and_return { 'BillTo' }
				bill_to.should_receive(:address)\
          .times(1).and_return { bill_addr }
				bill_addr.should_receive(:size)\
          .times(1).and_return { 2 }
				bill_addr.should_receive(:lines)\
          .times(1).and_return { ['BillLine1', 'BillLine2'] }
				bill_addr.should_receive(:city)\
          .times(1).and_return { 'BillCity' } 
				bill_addr.should_receive(:zip_code)\
          .times(1).and_return { 'BillZipCode' } 
				order.__next(:add_address) { |addr|
					assert_instance_of(I2::Address, addr)
					assert_equal(:buyer, addr.code)
					assert_equal('BillToId', addr.party_id)
					assert_equal('BillToName', addr.name1)
					assert_equal('BillLine1', addr.name2)
					assert_equal('BillLine2', addr.street1)
					assert_equal('BillCity', addr.city)
					assert_equal('BillZipCode', addr.zip_code)
					assert_equal(:buyer, addr.code)
				}

				BddI2._order_add_customer(order, customer)
				order.__verify
			end
			def test__order_add_party
				order = FlexMock.new('Order')
				party = FlexMock.new('Party')
				bdd_addr = FlexMock.new('Address')
				party.should_receive(:acc_id)\
          .times(1).and_return { 'id_string' }
				party.should_receive(:name)\
          .times(1).and_return { 'PartyName' }
				party.should_receive(:role)\
          .times(1).and_return { 'Employee' }
				party.should_receive(:address)\
          .times(1).and_return { bdd_addr }
				bdd_addr.should_receive(:size)\
          .times(1).and_return { 2 }
				bdd_addr.should_receive(:lines)\
          .times(1).and_return { 
					['Line1', 'Line2']	
				}
				bdd_addr.should_receive(:city)\
          .times(1).and_return { 'City' }
				bdd_addr.should_receive(:zip_code)\
          .times(1).and_return { 'ZipCode' }
				order.should_receive(:add_address)\
          .times(1).and_return { |addr|
					assert_equal(:employee, addr.code)
					assert_equal('id_string', addr.party_id)
					assert_equal('PartyName', addr.name1)
					assert_equal('Line1', addr.name2)
					assert_equal('Line2', addr.street1)
					assert_equal('City', addr.city)
					assert_equal('ZipCode', addr.zip_code)
				}
				BddI2._order_add_party(order, party)
			end
			def test__address_add_bdd_addr__0_lines
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.should_receive(:size)\
          .times(1).and_return { 0 }
				bdd_addr.should_receive(:lines)\
          .times(1).and_return { [] }
				bdd_addr.should_receive(:city)\
          .times(1).and_return { 'City' }
				bdd_addr.should_receive(:zip_code)\
          .times(1).and_return { 'ZipCode' }
				address.should_receive(:city=)\
          .times(1).and_return { |city| 
					assert_equal('City', city)
				}
				address.should_receive(:zip_code=)\
          .times(1).and_return { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
			end
			def test__address_add_bdd_addr__1_line
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.should_receive(:size)\
          .times(1).and_return { 1 }
				bdd_addr.should_receive(:lines)\
          .times(1).and_return {
					['Line1']
				}
				bdd_addr.should_receive(:city)\
          .times(1).and_return { 'City' }
				bdd_addr.should_receive(:zip_code)\
          .times(1).and_return { 'ZipCode' }
				address.should_receive(:street1=)\
          .times(1).and_return { |line|
					assert_equal('Line1', line)
				}
				address.should_receive(:street2=)\
          .times(1).and_return { |line|
					assert_nil(line)
				}
				address.should_receive(:city=)\
          .times(1).and_return { |city| 
					assert_equal('City', city)
				}
				address.should_receive(:zip_code=)\
          .times(1).and_return { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
			end
			def test__address_add_bdd_addr__2_lines
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.should_receive(:size)\
          .times(1).and_return { 2 }
				bdd_addr.should_receive(:lines)\
          .times(1).and_return {
					['Line1', 'Line2']
				}
				bdd_addr.should_receive(:city)\
          .times(1).and_return { 'City' }
				bdd_addr.should_receive(:zip_code)\
          .times(1).and_return { 'ZipCode' }
				address.should_receive(:name2=)\
          .times(1).and_return { |line|
					assert_equal('Line1', line)
				}
				address.should_receive(:street1=)\
          .times(1).and_return { |line|
					assert_equal('Line2', line)
				}
				address.should_receive(:street2=)\
          .times(1).and_return { |line|
					assert_nil(line)
				}
				address.should_receive(:city=)\
          .times(1).and_return { |city| 
					assert_equal('City', city)
				}
				address.should_receive(:zip_code=)\
          .times(1).and_return { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
			end
			def test__address_add_bdd_addr__3_lines
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.should_receive(:size)\
          .times(1).and_return { 3 }
				bdd_addr.should_receive(:lines)\
          .times(1).and_return {
					['Line1', 'Line2', 'Line3']
				}
				bdd_addr.should_receive(:city)\
          .times(1).and_return { 'City' }
				bdd_addr.should_receive(:zip_code)\
          .times(1).and_return { 'ZipCode' }
				address.should_receive(:name2=)\
          .times(1).and_return { |name|
					assert_equal('Line1', name)
				}
				address.should_receive(:street1=)\
          .times(1).and_return { |line|
					assert_equal('Line2', line)
				}
				address.should_receive(:street2=)\
          .times(1).and_return { |line|
					assert_equal('Line3', line)
				}
				address.should_receive(:city=)\
          .times(1).and_return { |city| 
					assert_equal('City', city)
				}
				address.should_receive(:zip_code=)\
          .times(1).and_return { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
			end
			def test__address_add_bdd_addr__more_than_3_lines
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.should_receive(:size)\
          .times(1).and_return { 9 }
				bdd_addr.should_receive(:lines)\
          .times(1).and_return {
					['Line1', 'Line2', 'Line3']
				}
				bdd_addr.should_receive(:city)\
          .times(1).and_return { 'City' }
				bdd_addr.should_receive(:zip_code)\
          .times(1).and_return { 'ZipCode' }
				address.should_receive(:name2=)\
          .times(1).and_return { |name|
					assert_equal('Line1', name)
				}
				address.should_receive(:street1=)\
          .times(1).and_return { |line|
					assert_equal('Line2', line)
				}
				address.should_receive(:street2=)\
          .times(1).and_return { |line|
					assert_equal('Line3', line)
				}
				address.should_receive(:city=)\
          .times(1).and_return { |city| 
					assert_equal('City', city)
				}
				address.should_receive(:zip_code=)\
          .times(1).and_return { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
			end
			def test__order_add_item__no_date
				order = FlexMock.new('Order')
				item = FlexMock.new('Item')
				item.should_receive(:line_no)\
          .times(1).and_return { 'LineNo' }
				item.should_receive(:et_nummer_id)\
          .times(1).and_return { 'EtNummerId' }
				item.should_receive(:pharmacode_id)\
          .times(1).and_return { 'Pharmacode' }
				item.should_receive(:customer_id)\
          .times(1).and_return { '12345' }
				item.should_receive(:qty)\
          .times(1).and_return { 17 }
				item.should_receive(:unit)\
          .times(1).and_return { }
				item.should_receive(:delivery_date)\
          .times(1).and_return { }
				item.should_receive(:get_price)\
          .times(1).and_return { }
				item.should_receive(:free_text)\
          .times(1).and_return { }
				order.should_receive(:add_position)\
          .times(1).and_return { |position|
					assert_instance_of(I2::Position, position)
					assert_equal('LineNo', position.number)
					assert_equal('12345', position.article_ean)
					assert_equal(17, position.qty)
					assert_nil(position.unit)
					assert_nil(position.delivery_date)
				}
				BddI2._order_add_item(order, item)
			end
			def test__order_add_item
				order = FlexMock.new('Order')
				item = FlexMock.new('Item')
				a_date = Date.new(1975,8,21)
				item.should_receive(:line_no)\
          .times(1).and_return { 'LineNo' }
				item.should_receive(:et_nummer_id)\
          .times(1).and_return { 'EtNummerId' }
				item.should_receive(:pharmacode_id)\
          .times(1).and_return { 'Pharmacode' }
				item.should_receive(:customer_id)\
          .times(1).and_return { '12345' }
				item.should_receive(:qty)\
          .times(1).and_return { 17 }
				item.should_receive(:unit)\
          .times(1).and_return { 'STK' }
				item.should_receive(:free_text)\
          .times(1).and_return { }
				item.should_receive(:delivery_date)\
          .times(1).and_return { a_date }
        price = FlexMock.new('Price')
        price.should_receive(:amount)\
          .times(1).and_return { '780.00' }
        item.should_receive(:get_price)\
          .times(1).and_return { |type|
          assert_equal('NettoPreis', type)
          price
        }
				order.should_receive(:add_position)\
          .times(1).and_return { |position|
					assert_instance_of(I2::Position, position)
					assert_equal('LineNo', position.number)
					assert_equal('12345', position.article_ean)
					assert_equal(17, position.qty)
					assert_equal('STK', position.unit)
					i2date = position.delivery_date
					assert_instance_of(I2::Date, i2date)
					assert_equal(a_date, i2date)
					assert_equal(:delivery, i2date.code)
          assert_equal('780.00', position.price)
				}
				BddI2._order_add_item(order, item)
			end
		end
	end
end
