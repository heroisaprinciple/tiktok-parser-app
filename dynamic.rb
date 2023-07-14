require 'selenium-webdriver'
require 'csv'
require 'byebug'
require 'nokogiri'

options = Selenium::WebDriver::Chrome::Options.new
options.headless!
driver = Selenium::WebDriver.for(:chrome)

driver.get 'https://quotes.toscrape.com/js/'
document = Nokogiri::HTML(driver.page_source)

quotes = []
while true do
  quote_container = driver.find_elements(css: '.quote')
  quote_container.each do |container|
    quote_text = container.find_element(css: '.text').attribute('textContent')
    author = container.find_element(css: '.author').attribute('textContent')
    quotes << [quote_text, author]
  end
  begin
    driver.find_element(css: '.next > a').click
  rescue
    break
  end
end

CSV.open('quotes.csv',
         'w+',
         write_headers: true,
         headers: %w[Quote Author]
) do |csv|
  quotes.each do |quote|
    csv << quote
  end
end