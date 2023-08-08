require 'csv'
require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'
require 'byebug'

URL = 'https://www.tiktok.com/search?q='
USER_URL = 'https://www.tiktok.com/@'
EMAIL_REGEX = /\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}\b/i
SOCIALS_REGEX = /\W(Twitter|IG|Insta(?:gram)?|Snapchat|Skype|Discord|Twitch):?\s?-?\s?\(?-?@?(\w+)\)?/i

# The class to process tiktok data.
class TikTokParser
  def initialize
    @driver = create_driver
    @wait = Selenium::WebDriver::Wait.new(timeout: 30)
  end

  def create_driver
    options = Selenium::WebDriver::Options.chrome
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--incognito')
    options.add_argument('--headless')
    options.add_argument('--window-size=1920,1080')

    Selenium::WebDriver.for :chrome, options: options
  end

  def scroll_to_bottom
    scroll_script = 'window.scrollTo(0, document.body.scrollHeight);'
    @driver.execute_script(scroll_script)
    sleep(2)
  end

  # Scrapes user data based on the specified query and number of queries wanted to display.
  #
  # @param query [String] The query to search for on TikTok.
  # @param number [Integer] The number of queries.
  # @return [Array<Array>] An array of user data, each represented as an array of values.
  def scrape_data(query, number)
    timestamp = (Time.now.to_f * 1000).to_i
    url = query.include?('#') ? "#{URL}#{query.gsub('#', '')}&=#{timestamp}"
            : "#{URL}#{query}&t=#{timestamp}"
    
    @driver.navigate.to(url)
    sleep(4)

    data = []
    counter = 0

    # TODO: refactor it
    loop do
      if counter % 12 == 0
        scroll_to_bottom
        sleep(3)
        names = @driver.find_elements(css: '[data-e2e="search-card-user-unique-id"]')
                       .map { |v| v.attribute('textContent') }
      end

      chunked_names = names.slice(counter, names.length)
      user_data = collect_user_info(chunked_names, counter, number)
      data.concat(user_data)
      counter += user_data.length

      if counter >= number
        @driver.quit
        break
      end
    end
    data
  end

  private

  # Collects user information for a chunk of users.
  #
  # @param names [Array<String>] Array of usernames to collect information for.
  # @param counter [Integer] Current count of collected user information.
  # @param number [Integer] Total number of user information to collect.
  # @return [Array<Array>] An array of user data, each represented as an array of values.

  # TODO: also, add scrolling functionality here
  def collect_user_info(names, counter, number)
    user_data = []

    names.each do |name|
      break if counter >= number

      user_url = "#{USER_URL}#{name}"
      sleep(3)
      user_data << [name, scrape_user_info(user_url)].flatten
      counter += 1
    end
    user_data
  end

  # Scrapes user data based on the specified query and number of users.
  #
  # @return [Array] An array of user data, each represented as an array of values.
  def scrape_user_info(user_url)
    res = HTTParty.get(user_url)
    docs = Nokogiri::HTML(res.body)

    followers_count = find_followers_amount(docs)
    avg_views = find_average_views(docs)
    description = find_description(docs)
    email = find_email(description)
    social_accounts = find_socials(description)

    [followers_count, avg_views, description, email, social_accounts]
  end

  # Finds the number of followers for a user based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [String] The number of followers for the user.
  def find_followers_amount(docs)
    docs.css('[data-e2e="followers-count"]').text
  end

  # Finds the average number of views for a user's videos based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [Float] The average number of views for the user's videos.
  def find_average_views(docs)
    avg_nums = docs.css('[data-e2e="video-views"]')
    average_views = avg_nums.sum { |el| el.text.to_f } / avg_nums.size unless avg_nums.empty?
    average_views&.round(2)
  end

  # Finds the description for a user based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [String] The description of the user's channel.
  def find_description(docs)
    description = docs.css('[data-e2e="user-bio"]')
    description.text
  end

  def find_email(desc)
    desc.scan(EMAIL_REGEX).join
  end

  def find_socials(desc)
    desc.scan(SOCIALS_REGEX)
        .map { |network, username| "#{network}: #{username}" }
        .join(' ')
  end
end
