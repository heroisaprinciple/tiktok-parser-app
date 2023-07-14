require 'csv'
require 'byebug'
require 'nokogiri'
require 'httparty'
require 'json'
require 'open-uri'
require 'selenium-webdriver'
require 'selenium/webdriver/common/wait'

puts 'Enter the query to use: '
query = gets.chomp
puts 'Also, include how many users and info about them you want to see. In essence, 10 users.'
number = gets.chomp.to_i

# tags: 'https://www.tiktok.com/tag/askingquestions'

# notitsmenicksmithy or jamesdoylefitness or bobbysolez or kerana0208 or yungalyy

url = query.include?('#') ? "https://www.tiktok.com/tag/#{query}" : "https://www.tiktok.com/search?q=#{query}"

driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(timeout: 30)

driver.get url

data = []
i = 1

while i < number do
  quote_container = wait.until { driver.find_elements(css: '.tiktok-hbrxqe-DivVideoSearchCardDesc.etrd4pu0') }
  quote_container.each do |container|
    name = container.find_element(css: '.tiktok-2zn17v-PUniqueId.etrd4pu6').attribute('textContent')
    user_url = "https://www.tiktok.com/@#{name}"
    res = HTTParty.get(user_url)
    docs = Nokogiri::HTML(res.body)
    # docs = docs.to_json
    puts('--------')

    account_els = docs.css('.tiktok-rxe1eo-DivNumber strong')
    followers_element = account_els.find { |el| el.attribute('title').value == 'Followers' }
    followers_count = followers_element.text
    p(followers_count.to_json)

    avg_nums = docs.css('.video-count')
    avg = avg_nums.map { |el| el.text.to_f }.sum / avg_nums.size

    description = docs.css('.tiktok-vdfu13-H2ShareDesc.e1457k4r3')
    desc = description.text
    email = desc.scan(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}\b/i).join
    social_accounts = desc.scan(/(Twitter|IG|Insta(?:gram)?|Snapchat|Skype|Youtube|Discord): ?\(?@?(\w+)\)?/i)
                          .map { |network, username| "#{network}: #{username}" }
                          .join(' ')
                          .gsub(/:\s/, ':')

    p social_accounts

    data << [name, followers_count, avg, desc, email, social_accounts]
    p data
    i += 1
  end
end

def generate_csv(data)
  CSV.open('tiktoker_followers.csv', 'w+',
           write_headers: true,
           headers: %w[Account Followers Avg_Views Channel_Desc Email Other_Accounts]) do |csv|
    data.each do |row|
      csv << row
    end
  end
end

generate_csv(data)