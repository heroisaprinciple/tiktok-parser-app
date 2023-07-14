require 'csv'
require 'byebug'
require 'nokogiri'
require 'httparty'
require 'json'
require 'open-uri'
require 'selenium-webdriver'
require 'selenium/webdriver/common/wait'

# puts "Enter the query to use: "
# query = gets.chomp
# url = "https://www.tiktok.com/search?q=#{query}"
# response = HTTParty.get(url)
# doc = Nokogiri::HTML(response.body)
#
# # accounts names
# accounts = doc.css(".tiktok-1u48guj-DivSearchContainer") # cats
# # tiktok-ubsdy8-DivVideoFeed eegew6e0
# # <div data-e2e="search_top-item-list" mode="search-video-list" class="tiktok-ubsdy8-DivVideoFeed eegew6e0"></div>
# puts accounts.first.children
# puts('-----')
# panel_containers = accounts.first.children.each{ |el| puts el }
# puts('aaaaaaaaaaaaaaaa')
# element = doc.at_css('div[data-e2e="search_top-item-list"][mode="search-video-list"].tiktok-ubsdy8-DivVideoFeed.eegew6e0')
# puts element.children

puts "Enter the query to use: "
query = gets.chomp
url = "https://www.tiktok.com/search?q=#{query}"

driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(timeout: 30) # Adjust the timeout as needed
driver.get url

# Wait until at least one matching element is present
# 'tiktok-22xkqc-StyledLink.er1vbsz0 video'
# tiktok-2zn17v-PUniqueId etrd4pu6
video_element = wait.until { driver.find_element(css: '.tiktok-2zn17v-PUniqueId.etrd4pu6') }
p video_element.text

while true do
  quote_container = wait.until { driver.find_elements(css: '.tiktok-hbrxqe-DivVideoSearchCardDesc.etrd4pu0') }
  quote_container.each do |container|
    quote_text = container.find_element(css: '.tiktok-2zn17v-PUniqueId.etrd4pu6').attribute('textContent')
    p quote_text
  end
end


# while true do
#   quote_container = driver.find_elements(css: '.tiktok-hbrxqe-DivVideoSearchCardDesc etrd4pu0')
#   quote_container.each do |container|
#     quote_text = container.find_element(css: '.text').attribute('textContent')
#     p quote_text
#   end
# end


# div id="tabs-0-panel-search_top" role="tabpanel" tabindex="0" aria-labelledby="tabs-0-tab-search_top" class="tiktok-1fwlm1o-DivPanelContainer ea3pfar3">
# <style data-emotion="tiktok 1qb12g8-DivThreeColumnContainer">.tiktok-1qb12g8-DivThreeColumnContainer{width:100%;}</style>
# <div class="tiktok-1qb12g8-DivThreeColumnContainer eegew6e2">
# <style data-emotion="tiktok ubsdy8-DivVideoFeed">.tiktok-ubsdy8-DivVideoFeed{display:-webkit-box;display:-webkit-flex;display:-ms-flexbox;display:flex;-webkit-box-flex-wrap:wrap;-webkit-flex-wrap:wrap;-ms-flex-wrap:wrap;flex-wrap:wrap;}.tiktok-ubsdy8-DivVideoFeed::after{content:"";height:0;display:block;clear:both;}@media screen and (max-width: 767px){.tiktok-ubsdy8-DivVideoFeed{width:100%;}}</style>
# <div data-e2e="search_top-item-list" mode="search-video-list" class="tiktok-ubsdy8-DivVideoFeed eegew6e0"></div>
#
# element = doc.at_css('div')
# element.children.each do |el|
#   if el['class'] == 'tiktok-ubsdy8-DivVideoFeed eegew6e0'
#     puts el
#   end
# end

# puts "Enter the name of the tiktoker: "
# user_name = gets.chomp
# url = "https://www.tiktok.com/@#{user_name}"
# response = HTTParty.get(url)
# doc = Nokogiri::HTML(response.body) # itsmenicksmithy2 or wwsaqrigdpc
#
# # N of followers
# account_els = doc.css(".tiktok-rxe1eo-DivNumber strong")
# followers_element = account_els.find { |el| el.attribute('title').value == 'Followers' }
# followers_count = followers_element.text
# puts "Number of followers: #{followers_count}"
#
# # avg n of views
# avg_nums = doc.css(".video-count")
# avg = avg_nums.map { |el| el.text.to_f }.sum / avg_nums.size
# puts "The average num of views: #{avg}"
#
# def generate_csv(data)
#   CSV.open('tiktoker_followers.csv', 'w+',
#            write_headers: true,
#            headers: %w[Account Followers Avg Views ]) do |csv|
#     data.each do |row|
#       csv << row
#     end
#   end
# end
#
# generate_csv([[user_name, followers_count]])