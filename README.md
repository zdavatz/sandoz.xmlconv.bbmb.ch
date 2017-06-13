# sandoz.xmlconv.bbmb.ch

## Description

The xml converter files for Sandoz Switzerland.

graphical overview:
![sandozxmlconv](https://raw.githubusercontent.com/zdavatz/sandoz.xmlconv.bbmb.ch/master/sandozxmlconv.jpeg)

## Repository

https://github.com/zdavatz/sandoz.xmlconv.bbmb.ch

## Requirements

* xmlconv
* sbsm
* odba
* soap4r
* yus (runtime)

See `Gemfile`

## Install

```bash
$ git clone https://github.com/zdavatz/sandoz.xmlconv.bbmb.ch.git
$ mkdir -p log var/output
```

## Setup

* bundle install
* create and adapt etc/polling.yml
* create and adapt etc/config.yml
* integrate it with apache
* setup yus (authentication) server

```bash
# xmlconvd
$ bundle exec rackup

# bin/admin

Use something like `sudo -u bbmb /usr/local/bin/ruby-240 /usr/local/bin/xmlconv_admin config=/var/www/sandoz.xmlconv.bbmb.ch/etc/xmlconv.yml`
# yusd
$ bundle exec yusd config=/path/to/etc/yus.yml
```

## Testing

```bash
# feature test using watir (rspec)
$ bundle exec rake spec

# unit-test and integration test (minitest)
$ bundle exec rake test
```

### soap request for generating an invoice

`curl -v http://sandoz.xmlconv.bbmb.ngiger.ch/propharma -d@test/data/confuse.xml`

where test/data/confuse.xml is a file and sandoz.xmlconv.bbmb.ngiger.ch your testing domain.

The command should have a result status of 0 and respond with something like
  *   Trying 62.12.131.46...
  * TCP_NODELAY set
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                  Dload  Upload   Total   Spent    Left  Speed
    0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0* Connected to sandoz.xmlconv.bbmb.ch (62.12.131.46) port 80 (#0)
  > POST /propharma HTTP/1.1
  > Host: sandoz.xmlconv.bbmb.ch
  > User-Agent: curl/7.50.3
  > Accept: */*
  > Content-Length: 625
  > Content-Type: application/x-www-form-urlencoded
  >
  } [625 bytes data]
  * upload completely sent off: 629 out of 629 bytes
  < HTTP/1.1 200 OK
  < Date: Mon, 12 Jun 2017 12:15:03 GMT
  * Server WEBrick/1.3.1 (Ruby/2.4.0/2016-12-24) is not blacklisted
  < Server: WEBrick/1.3.1 (Ruby/2.4.0/2016-12-24)
  < Content-Length: 0
  < Content-Type: text/html;charset=UTF-8
  < Set-Cookie: _session_id=3c2b018a11c1438855db71923b; path=/
  <
  <?xml version='1.0' encoding='UTF-8'?>
  <customerOrderResponse xmlns='http://www.e-galexis.com/schemas/' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://www.e-galexis.com/schemas/ http://www.e-galexis.com/schemas/POS/customerOrder/customerOrderResponse.xsd' version='1.0' roundUpForCondition='false' backLogDesired='false' language='de' productDescriptionDesired='false'>
    <clientResponse number='99-130'/>
    <orderHeaderResponse referenceNumber='99'>
      <deliveryAddress/>
    </orderHeaderResponse>
    <orderLinesResponse>
      <productOrderLineResponse lineAccepted='true' backLogLine='false' roundUpForConditionDone='false' productReplaced='false'>
        <productOrderLine orderQuantity='2'>
          <pharmaCode id='2508375'/>
        </productOrderLine>
        <productResponse wholesalerProductCode='44060678' description='Cip eco 250 mg Filmtabl 10'/>
        <availability status='yes'/>
      </productOrderLineResponse>
      <productOrderLineResponse lineAccepted='true' backLogLine='false' roundUpForConditionDone='false' productReplaced='false'>
        <productOrderLine orderQuantity='2'>
          <pharmaCode id='5195126'/>
        </productOrderLine>
        <productResponse wholesalerProductCode='05201388' description='Candesartan Sandoz 8 mg Tbl 98'/>
        <availability status='yes'/>
      </productOrderLineResponse>
    </orderLinesResponse>
  </customerOrderResponse
  * Connection #0 to host sandoz.xmlconv.bbmb.ngiger.ch left intact

  80.218.53.88 - - [31/May/2017:15:12:03 +0200] "POST /propharma HTTP/1.1" 500 - "-" "curl/7.50.3"

Verify in the admin web interface:
  * that a new transaction is generated
  * that the fiel 'Absender' contains the correct remote IP address (numerically)
  * it status is 'Bestellung via BBMB erfolgreich'
  * its detail contains the correct orderlines

Verify in your sandoz.bbmb.ch that
  * the user 99 lists also the new order

It is normal to see polling errors, as long as you dont specify a valid pop

## Developers

* Zeno R.R. Davatz
* Masaomi Hatakeyama
* Hannes Wyss (up to Version 1.0.0)
* Niklaus Giger (ported to Ruby 2.3)

## License

GPLv2
