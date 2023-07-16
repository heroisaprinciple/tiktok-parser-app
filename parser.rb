# frozen_string_literal: true

require 'csv'
require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'
require 'byebug'

TAG_URL = "https://www.tiktok.com/tag/"
KEYWORD_URL = "https://www.tiktok.com/search?q="
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
        video_container = @wait.until { @driver.find_elements(css: '.tiktok-hbrxqe-DivVideoSearchCardDesc.etrd4pu0') }
        video_container.each do |container|
          name = find_name(container)
          user_url = "https://www.tiktok.com/@#{name}"
          data << [name, scrape_user_info(user_url)].flatten
          i += 1
          break if i >= number
        end
      else
        containers_usernames = @wait.until { @driver.find_elements(css: '.user-name.tiktok-1gi42ki-PUserName.exdlci15') }
        names = containers_usernames.map { |v| v.attribute('textContent') }

        names.each do |name|
          user_url = "https://www.tiktok.com/@#{name}"
          data << [name, scrape_user_info(user_url)].flatten
          i += 1
          break if i >= number
        end
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
  def find_name(container)
    container.find_element(css: '.tiktok-2zn17v-PUniqueId.etrd4pu6').attribute('textContent')
  end

  # Finds the number of followers for a user based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [String] The number of followers for the user.
  def find_followers_amount(docs)
    account_els = docs.css('.tiktok-rxe1eo-DivNumber strong')
    followers_element = account_els.find { |el| el.attribute('title').value == 'Followers' }
    followers_element.text
  end

  # Finds the average number of views for a user's videos based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [Float] The average number of views for the user's videos.
  def find_average_views(docs)
    avg_nums = docs.css('.video-count')
    avg_nums.map { |el| el.text.to_f }.sum / avg_nums.size
  end

  # Finds the description for a user based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [String] The description of the user's channel.
  def find_description(docs)
    description = docs.css('.tiktok-vdfu13-H2ShareDesc.e1457k4r3')
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
