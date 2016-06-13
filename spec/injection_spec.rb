#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
@workThread = nil
CustomerId = 4100614181
ProductName = 'Bilol 2.5 mg Filmtbl 100'
Here = File.expand_path(File.dirname(__FILE__))

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

  describe "admin" do
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
    it "handle an injection properly" do
        total_before, item_before = get_total_and_item_total
        puts "Before #{total_before} item  #{item_before}"
        inject_invoice
        # binding.pry
        logout
        login(AdminUser, AdminPassword)
        total_after, item_after = get_total_and_item_total
        puts "After #{total_after} item  #{item_after}"
        diff_total = total_after - total_before
        diff_item= item_after - item_before
        puts "diff_item #{diff_item} diff_total  #{diff_total}"
    end
  end

  def inject_invoice
    filename = File.join(Here, 'data', 'invoice.xml')
    expect(File.exists?(filename)).to be true
    cmd = "curl http://sandoz.xmlconv.bbmb.ngiger.ch/propharma -X POST -H 'Content-type: text/xml' --data @#{filename}"
    expect(system(cmd)).to be true
  end

  def get_total_and_item_total
      @browser.goto "#{BbmbUrl}/de/#{Flavor}/customer/customer_id/#{CustomerId}"
      windowSize = @browser.windows.size
      expect(@browser.url).to match BbmbUrl
      text = @browser.text.clone
      expect(@browser.url).to match BbmbUrl
      expect(@browser.url).to match CustomerId.to_s
      how_much = @browser.link(:name => 'turnover').text
      @turnover = how_much.match(/(\d+\.\d+)/)[1].to_f
      @browser.link(:name => 'history').click
      expect(@browser.url).to match BbmbUrl
      expect(@browser.url).to match CustomerId.to_s
      expect(@browser.url).to match 'history'
      wieviel = @browser.text.match(/#{ProductName}\s+\d+\.\d+\s+(\d+\.\d+)/)
      @item_turnover = wieviel[1].to_f
      return @turnover, @item_turnover
  end
end
