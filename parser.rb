require 'csv'
require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'
require 'byebug'

TAG_URL = "https://www.tiktok.com/tag/"
KEYWORD_URL = "https://www.tiktok.com/search?q="
USER_URL = "https://www.tiktok.com/@"
EMAIL_REGEX = /\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}\b/i
SOCIALS_REGEX = /\W(Twitter|IG|Insta(?:gram)?|Snapchat|Skype|Discord|Twitch):?\s?-?\s?\(?-?@?(\w+)\)?/i

# The class to process tiktok data.
class TikTokParser
  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(timeout: 30)
  end

  # Scrapes user data based on the specified query and number of queries wanted to display.
  #
  # @param query [String] The query to search for on TikTok.
  # @param number [Integer] The number of queries.
  # @return [Array<Array>] An array of user data, each represented as an array of values.
  def scrape_data(query, number)
    url = query.include?('#') ? "#{TAG_URL}#{query.gsub('#', '')}" : "#{KEYWORD_URL}#{query}"
    @driver.get(url)

    data = []
    i = 0

    while i < number
      if !query.include?('#')
        names = @wait.until { @driver.find_elements(css: '[data-e2e="search-card-user-unique-id"]') }
                               .map { |v| v.attribute('textContent') }
      else
        names = @wait.until { @driver.find_elements(css: '[data-e2e="challenge-item-username"]') }
                     .map { |v| v.attribute('textContent') }
      end

      names.each do |name|
        user_url = "#{USER_URL}#{name}"
        data << [name, scrape_user_info(user_url)].flatten
        i += 1
        break if i >= number
      end
    end

    @driver.quit
    data
  end

  private

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

  # Finds the name of a user based on the provided container element.
  #
  # @param container [SeleniumWebElement] The container element containing the user information.
  # @return [String] The name of the user.
  # def find_name(container)
  #   container.find_element(css: '[data-e2e="search-card-user-unique-id"]').attribute('textContent')
  # end

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
