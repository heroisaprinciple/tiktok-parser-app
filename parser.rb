require 'csv'
require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'
require 'byebug'

class TikTokParser
  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(timeout: 30)
  end

  def scrape_user_data(query, number)
    url = query.include?('#') ? "https://www.tiktok.com/tag/#{query}".gsub('#', '') : "https://www.tiktok.com/search?q=#{query}"
    @driver.get(url)

    data = []
    i = 0

    # username for tags urls
    containers_usernames = @wait.until { @driver.find_elements(css: '.user-name.tiktok-1gi42ki-PUserName.exdlci15') }
    names = containers_usernames.each do |v|
      v.attribute('textContent')
    end

    while i < number
      video_container = @wait.until { @driver.find_elements(css: '.tiktok-hbrxqe-DivVideoSearchCardDesc.etrd4pu0') }

      video_container.each do |container|
        name = find_name(container)
        user_url = "https://www.tiktok.com/@#{name}"
        res = HTTParty.get(user_url)
        docs = Nokogiri::HTML(res.body)

        followers_count = find_followers_amount(docs)
        avg_views = find_average_views(docs)
        description = find_description(docs)
        email = find_email(description)
        social_accounts = find_socials(description)

        data << [name, followers_count, avg_views, description, email, social_accounts]
        p data
        i += 1
        break if i >= number
      end
    end

    @driver.quit
    data
  end

  def call_generate_csv(data)
    generate_csv(data)
  end

  private

  def find_name(container)
    container.find_element(css: '.tiktok-2zn17v-PUniqueId.etrd4pu6').attribute('textContent')
  end

  # def find_name_for_tags()
  #   container.
  # end

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
    CSV.open('tiktok_data.csv', 'w+', write_headers: true,
             headers: %w[Account Followers Avg_Views Channel_Desc Email Other_Accounts]) do |csv|
      data.each do |row|
        csv << row
      end
    end
  end
end

# tags: 'https://www.tiktok.com/tag/askingquestions'

# notitsmenicksmithy or jamesdoylefitness or bobbysolez or kerana0208 or yungalyy

puts 'Enter the query to use:'
query = gets.chomp
puts 'Enter the number of users and info about them you want to see (e.g., 10):'
number = gets.chomp.to_i

scraper = TikTokParser.new
data = scraper.scrape_user_data(query, number)
scraper.call_generate_csv(data)
