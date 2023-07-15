require 'csv'
require 'byebug'
require 'nokogiri'
require 'httparty'
require 'json'
require 'open-uri'
require 'selenium-webdriver'
require 'selenium/webdriver/common/wait'

puts 'Enter the query to use: '
$query = gets.chomp
puts 'Also, include how many users and info about them you want to see. In essence, 10 users.'
$number = gets.chomp.to_i

# tags: 'https://www.tiktok.com/tag/askingquestions'

# notitsmenicksmithy or jamesdoylefitness or bobbysolez or kerana0208 or yungalyy

url = $query.include?('#') ? "https://www.tiktok.com/tag/#{$query}".gsub('#', '') : "https://www.tiktok.com/search?q=#{$query}"

$driver = Selenium::WebDriver.for :chrome
$wait = Selenium::WebDriver::Wait.new(timeout: 30)

# class for p for #: 'tiktok-18g0m3y-PInfo-StyledH3UniqueId e1aajktk12'
$driver.get url

# if just word
def parsing_by_keyword
  data = []
  i = 1

  while i < $number do
    video_container = $wait.until { $driver.find_elements(css: '.tiktok-hbrxqe-DivVideoSearchCardDesc.etrd4pu0') }
    video_container.each do |container|
      name = find_name(container)
      user_url = "https://www.tiktok.com/@#{name}"
      res = HTTParty.get(user_url)
      docs = Nokogiri::HTML(res.body)

      followers_count = find_followers_amount(docs)

      avg = find_average_views(docs)

      desc = find_description(docs)

      email = find_email(desc)

      social_accounts = find_socials(desc)

      data << [name, followers_count, avg, desc, email, social_accounts]
      p data
      i += 1
    end
  end
end

def find_name(container)
  container.find_element(css: '.tiktok-2zn17v-PUniqueId.etrd4pu6').attribute('textContent')
end

def find_followers_amount(docs)
  account_els = docs.css('.tiktok-rxe1eo-DivNumber strong')
  followers_element = account_els.find { |el| el.attribute('title').value == 'Followers' }
  followers_element.text
end

def find_average_views(docs)
  avg_nums = docs.css('.video-count')
  avg_nums.map { |el| el.text.to_f }.sum / avg_nums.size
end

def find_description(docs)
  description = docs.css('.tiktok-vdfu13-H2ShareDesc.e1457k4r3')
  description.text
end

def find_email(desc)
  desc.scan(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}\b/i).join
end

def find_socials(desc)
  desc.scan(/(Twitter|IG|Insta(?:gram)?|Snapchat|Skype|Youtube|Discord): ?\(?@?(\w+)\)?/i)
      .map { |network, username| "#{network}: #{username}" }
      .join(' ')
      .gsub(/:\s/, ':')
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

parsing_by_keyword
generate_csv(data)