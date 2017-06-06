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
  * upload completely sent off: 625 out of 625 bytes
  < HTTP/1.1 500 Internal Server Error
  < Date: Wed, 31 May 2017 13:12:03 GMT
  < Server: Apache
  < Content-Length: 0
  < Connection: close
  < Content-Type: text/xml;charset=utf-8
  <
  * Curl_http_done: called premature == 0
  100   625    0     0  100   625      0   9583 --:--:-- --:--:-- --:--:-- 14880
  * Closing connection 0
`

On the server you should see in the apache log something (where 80.218.53.88 is your IP-address) like this. The error code is 500 because it is not handled by a propharma.rb file.

  80.218.53.88 - - [31/May/2017:15:12:03 +0200] "POST /propharma HTTP/1.1" 500 - "-" "curl/7.50.3"


It is normal to see polling errors, as long as you dont specify a valid pop

## Developers

* Zeno R.R. Davatz
* Masaomi Hatakeyama
* Hannes Wyss (up to Version 1.0.0)
* Niklaus Giger (ported to Ruby 2.3)

## License

GPLv2
