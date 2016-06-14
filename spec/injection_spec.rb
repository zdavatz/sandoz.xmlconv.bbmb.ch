#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
@workThread = nil
Here = File.expand_path(File.dirname(__FILE__))

XmlConvTest = Struct.new("XmlConvTest", :name, :customer_id, :product_name, :diff_total, :diff_item,)

describe "bbmb.xmlconv" do

  before :all do
    @idx = 0
    waitForBbmbToBeReady(@browser, BbmbUrl)
  end
  
  before :each do
    @browser.goto BbmbUrl
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    logout
  end

  after :all do
    @browser.close
  end

  describe "xmlconv" do
    before :all do
    end
    before :each do
      @browser.goto BbmbUrl
      logout
      login(AdminUser, AdminPassword)
    end
    after :all do
      logout
    end

    tests = [ XmlConvTest.new('propharma', 4100612722, 'Bilol 2.5 mg Filmtbl 100', 310.62, 30.3),
              ]
    tests.each do |xml_conv_test|
      puts xml_conv_test
      it "handle injection via xml_conv_test.name" do
        total_before, item_before = get_total_and_item_total(xml_conv_test.customer_id, xml_conv_test.product_name)
        puts "Before #{total_before} item  #{item_before}"
        inject_invoice(xml_conv_test.name)
        logout
        login(AdminUser, AdminPassword)
        total_after, item_after = get_total_and_item_total(xml_conv_test.customer_id, xml_conv_test.product_name)
        puts "After #{total_after} item  #{item_after}"
        diff_total = total_after - total_before
        diff_item= item_after - item_before
        puts "diff_item #{diff_item} diff_total  #{diff_total}"
        expect(diff_total).to be_within(0.01).of(xml_conv_test.diff_total)
        # expect(diff_item).to be_within(0.01).of(xml_conv_test.diff_item)
      end
    end
  end

  def inject_invoice(name)
    filename = File.join(Here, 'data', "#{name}.xml")
    expect(File.exists?(filename)).to be true
    cmd = "curl http://sandoz.xmlconv.bbmb.ngiger.ch/#{name} -X POST -H 'Content-type: text/xml' --data @#{filename}"
    res = `#{cmd}`
    expect(res.length).to be > 0
    expect(res).to match 'orderLinesResponse'
  end

  def get_total_and_item_total(customer_id, product_name)
      @browser.goto "#{BbmbUrl}/de/#{Flavor}/customer/customer_id/#{customer_id}"
      windowSize = @browser.windows.size
      expect(@browser.url).to match BbmbUrl
      text = @browser.text.clone
      expect(@browser.url).to match BbmbUrl
      expect(@browser.url).to match customer_id.to_s
      how_much = @browser.link(:name => 'turnover').text
      turnover = how_much.match(/(\d+\.\d+)/)[1].to_f
      @browser.link(:name => 'history').click
      expect(@browser.url).to match BbmbUrl
      expect(@browser.url).to match customer_id.to_s
      expect(@browser.url).to match 'history'
      wieviel = @browser.text.match(/#{product_name}\s+\d+\.\d+\s+(\d+\.\d+)/)
      item_turnover = wieviel[1].to_f
      return turnover, item_turnover
  end
end
