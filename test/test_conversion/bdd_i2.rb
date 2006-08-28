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
        agreement.mock_handle(:terms_cond) { 'camion' }
        bsr = FlexMock.new
        bsr.mock_handle(:interface) { }
        bsr.mock_handle(:customer) { }
				delivery = FlexMock.new
        delivery.mock_handle(:bsr) { bsr }
				delivery.mock_handle(:bsr_id) { 'BSR-ID' }
				delivery.mock_handle(:customer_id) { '1234' }
				delivery.mock_handle(:customer) {}
				delivery.mock_handle(:seller) {}
				delivery.mock_handle(:free_text) {}
				delivery.mock_handle(:delivery_date) {}
				delivery.mock_handle(:transport_cost) {}
				delivery.mock_handle(:agreement) { agreement }
				delivery.mock_handle(:items) { [] }
				bdd = FlexMock.new
				bdd.mock_handle(:deliveries) { [delivery] }
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
        agreement.mock_handle(:terms_cond) { 'camion' }
				delivery = FlexMock.new
				delivery.mock_handle(:customer_id) { 'Customer-Delivery-Id' }
				delivery.mock_handle(:bsr) { }
				delivery.mock_handle(:bsr_id) { 'BSR-ID' }
				delivery.mock_handle(:customer) {}
				delivery.mock_handle(:delivery_date) {}
				delivery.mock_handle(:transport_cost) {}
				delivery.mock_handle(:seller) {}
				delivery.mock_handle(:free_text) {}
				delivery.mock_handle(:agreement) { agreement }
				delivery.mock_handle(:items) { [] }
				BddI2._doc_add_delivery(doc, delivery)
				order = doc.orders.first
				assert_equal('YWESEE', order.sender_id)
				assert_equal('Customer-Delivery-Id', order.delivery_id)
				assert_equal(:default, order.terms_cond)
				delivery.mock_verify
			end
			def test__order_add_customer
				order = Mock.new('Order')
				customer = FlexMock.new('Customer')
				employee = FlexMock.new('Employee')
				bill_to = FlexMock.new('BillTo')
				ship_to = FlexMock.new('ShipTo')
				bill_addr = FlexMock.new('BillAddress')
				ship_addr = FlexMock.new('ShipAddress')
				customer.mock_handle(:parties) {
					[employee, ship_to, bill_to]
				}
				employee.mock_handle(:acc_id) { }
				employee.mock_handle(:name) { 'EmployeeName' }
				employee.mock_handle(:role) { 'Employee' }
				employee.mock_handle(:address) { }
				order.__next(:add_address) { |addr|
					assert_instance_of(I2::Address, addr)
					assert_equal(:employee, addr.code)
					assert_nil(addr.party_id)
					assert_equal('EmployeeName', addr.name1)
				}

				ship_to.mock_handle(:acc_id) { }
				ship_to.mock_handle(:name) { 'Name' }
				ship_to.mock_handle(:role) { 'ShipTo' }
				ship_to.mock_handle(:address) { ship_addr }
				ship_addr.mock_handle(:size) { 0 }
				ship_addr.mock_handle(:lines) { [] }
				ship_addr.mock_handle(:city) { 'City' } 
				ship_addr.mock_handle(:zip_code) { 'ZipCode' } 
				order.__next(:add_address) { |addr|
					assert_instance_of(I2::Address, addr)
					assert_equal(:delivery, addr.code)
					assert_equal('Name', addr.name1)
					assert_equal('City', addr.city)
					assert_equal('ZipCode', addr.zip_code)
				}

				bill_to.mock_handle(:acc_id) { 'BillToId' }
				bill_to.mock_handle(:name) { 'BillToName' }
				bill_to.mock_handle(:role) { 'BillTo' }
				bill_to.mock_handle(:address) { bill_addr }
				bill_addr.mock_handle(:size) { 2 }
				bill_addr.mock_handle(:lines) { ['BillLine1', 'BillLine2'] }
				bill_addr.mock_handle(:city) { 'BillCity' } 
				bill_addr.mock_handle(:zip_code) { 'BillZipCode' } 
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
				customer.mock_verify
				employee.mock_verify
				bill_to.mock_verify
				bill_addr.mock_verify
				ship_to.mock_verify
				ship_addr.mock_verify
			end
			def test__order_add_party
				order = FlexMock.new('Order')
				party = FlexMock.new('Party')
				bdd_addr = FlexMock.new('Address')
				party.mock_handle(:acc_id) { 'id_string' }
				party.mock_handle(:name) { 'PartyName' }
				party.mock_handle(:role) { 'Employee' }
				party.mock_handle(:address) { bdd_addr }
				bdd_addr.mock_handle(:size) { 2 }
				bdd_addr.mock_handle(:lines) { 
					['Line1', 'Line2']	
				}
				bdd_addr.mock_handle(:city) { 'City' }
				bdd_addr.mock_handle(:zip_code) { 'ZipCode' }
				order.mock_handle(:add_address) { |addr|
					assert_equal(:employee, addr.code)
					assert_equal('id_string', addr.party_id)
					assert_equal('PartyName', addr.name1)
					assert_equal('Line1', addr.name2)
					assert_equal('Line2', addr.street1)
					assert_equal('City', addr.city)
					assert_equal('ZipCode', addr.zip_code)
				}
				BddI2._order_add_party(order, party)
				order.mock_verify
				party.mock_verify
				bdd_addr.mock_verify
			end
			def test__address_add_bdd_addr__0_lines
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.mock_handle(:size) { 0 }
				bdd_addr.mock_handle(:lines) { [] }
				bdd_addr.mock_handle(:city) { 'City' }
				bdd_addr.mock_handle(:zip_code) { 'ZipCode' }
				address.mock_handle(:city=) { |city| 
					assert_equal('City', city)
				}
				address.mock_handle(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.mock_verify
				bdd_addr.mock_verify
			end
			def test__address_add_bdd_addr__1_line
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.mock_handle(:size) { 1 }
				bdd_addr.mock_handle(:lines) {
					['Line1']
				}
				bdd_addr.mock_handle(:city) { 'City' }
				bdd_addr.mock_handle(:zip_code) { 'ZipCode' }
				address.mock_handle(:street1=) { |line|
					assert_equal('Line1', line)
				}
				address.mock_handle(:street2=) { |line|
					assert_nil(line)
				}
				address.mock_handle(:city=) { |city| 
					assert_equal('City', city)
				}
				address.mock_handle(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.mock_verify
				bdd_addr.mock_verify
			end
			def test__address_add_bdd_addr__2_lines
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.mock_handle(:size) { 2 }
				bdd_addr.mock_handle(:lines) {
					['Line1', 'Line2']
				}
				bdd_addr.mock_handle(:city) { 'City' }
				bdd_addr.mock_handle(:zip_code) { 'ZipCode' }
				address.mock_handle(:name2=) { |line|
					assert_equal('Line1', line)
				}
				address.mock_handle(:street1=) { |line|
					assert_equal('Line2', line)
				}
				address.mock_handle(:street2=) { |line|
					assert_nil(line)
				}
				address.mock_handle(:city=) { |city| 
					assert_equal('City', city)
				}
				address.mock_handle(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.mock_verify
				bdd_addr.mock_verify
			end
			def test__address_add_bdd_addr__3_lines
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.mock_handle(:size) { 3 }
				bdd_addr.mock_handle(:lines) {
					['Line1', 'Line2', 'Line3']
				}
				bdd_addr.mock_handle(:city) { 'City' }
				bdd_addr.mock_handle(:zip_code) { 'ZipCode' }
				address.mock_handle(:name2=) { |name|
					assert_equal('Line1', name)
				}
				address.mock_handle(:street1=) { |line|
					assert_equal('Line2', line)
				}
				address.mock_handle(:street2=) { |line|
					assert_equal('Line3', line)
				}
				address.mock_handle(:city=) { |city| 
					assert_equal('City', city)
				}
				address.mock_handle(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.mock_verify
				bdd_addr.mock_verify
			end
			def test__address_add_bdd_addr__more_than_3_lines
				address = FlexMock.new('Address')
				bdd_addr = FlexMock.new('BddAddress')
				bdd_addr.mock_handle(:size) { 9 }
				bdd_addr.mock_handle(:lines) {
					['Line1', 'Line2', 'Line3']
				}
				bdd_addr.mock_handle(:city) { 'City' }
				bdd_addr.mock_handle(:zip_code) { 'ZipCode' }
				address.mock_handle(:name2=) { |name|
					assert_equal('Line1', name)
				}
				address.mock_handle(:street1=) { |line|
					assert_equal('Line2', line)
				}
				address.mock_handle(:street2=) { |line|
					assert_equal('Line3', line)
				}
				address.mock_handle(:city=) { |city| 
					assert_equal('City', city)
				}
				address.mock_handle(:zip_code=) { |zip_code|
					assert_equal('ZipCode', zip_code)
				}
				BddI2._address_add_bdd_addr(address, bdd_addr)
				address.mock_verify
				bdd_addr.mock_verify
			end
			def test__order_add_item__no_date
				order = FlexMock.new('Order')
				item = FlexMock.new('Item')
				item.mock_handle(:line_no) { 'LineNo' }
				item.mock_handle(:et_nummer_id) { 'EtNummerId' }
				item.mock_handle(:pharmacode_id) { 'Pharmacode' }
				item.mock_handle(:customer_id) { '12345' }
				item.mock_handle(:qty) { 17 }
				item.mock_handle(:unit) { }
				item.mock_handle(:delivery_date) { }
				item.mock_handle(:get_price) { }
				item.mock_handle(:free_text) { }
				order.mock_handle(:add_position) { |position|
					assert_instance_of(I2::Position, position)
					assert_equal('LineNo', position.number)
					assert_equal('12345', position.article_ean)
					assert_equal(17, position.qty)
					assert_nil(position.unit)
					assert_nil(position.delivery_date)
				}
				BddI2._order_add_item(order, item)
				order.mock_verify
				item.mock_verify
			end
			def test__order_add_item
				order = FlexMock.new('Order')
				item = FlexMock.new('Item')
				a_date = Date.new(1975,8,21)
				item.mock_handle(:line_no) { 'LineNo' }
				item.mock_handle(:et_nummer_id) { 'EtNummerId' }
				item.mock_handle(:pharmacode_id) { 'Pharmacode' }
				item.mock_handle(:customer_id) { '12345' }
				item.mock_handle(:qty) { 17 }
				item.mock_handle(:unit) { 'STK' }
				item.mock_handle(:free_text) { }
				item.mock_handle(:delivery_date) { a_date }
        price = FlexMock.new('Price')
        price.mock_handle(:amount) { '780.00' }
        item.mock_handle(:get_price) { |type|
          assert_equal('NettoPreis', type)
          price
        }
				order.mock_handle(:add_position) { |position|
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
				order.mock_verify
				item.mock_verify
			end
		end
	end
end
