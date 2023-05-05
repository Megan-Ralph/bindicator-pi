require 'httparty'
require 'nokogiri'
require 'pi_piper'

GREEN_PIN = 17
GREY_PIN = 18
BROWN_PIN = 19

URL = 'https://www.wirral.gov.uk/bins-and-recycling/bin-collection-dates'

street_name = ENV['STREET_NAME']
response = HTTParty.post(URL, body: { s: street_name })
doc = Nokogiri::HTML(response.body)
date_div = doc.css('.panel--body .table-wrapper div:first-child').first

green_date = Date.parse(date_div.css('.table--bin-collections tr:nth-child(1) td:last-child').text.strip)
grey_date = Date.parse(date_div.css('.table--bin-collections tr:nth-child(2) td:last-child').text.strip)
brown_date = Date.parse(date_div.css('.table--bin-collections tr:nth-child(3) td:last-child').text.strip)

today = Date.today
if today == green_date
  bin_color = 'green'
elsif today == grey_date
  bin_color = 'grey'
elsif today == brown_date
  bin_color = 'brown'
else
  bin_color = 'off'
end

case bin_color
when 'green'
  pin = GREEN_PIN
when 'grey'
  pin = GREY_PIN
when 'brown'
  pin = BROWN_PIN
else
  PiPiper::Pin.off(GREEN_PIN)
  PiPiper::Pin.off(GREY_PIN)
  PiPiper::Pin.off(BROWN_PIN)
  exit
end

PiPiper::Pin.set(pin, 1)
PiPiper::Pin.off(GREEN_PIN) if pin != GREEN_PIN
PiPiper::Pin.off(GREY_PIN) if pin != GREY_PIN
PiPiper::Pin.off(BROWN_PIN) if pin != BROWN_PIN
