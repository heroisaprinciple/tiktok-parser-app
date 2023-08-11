require 'csv'
require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'
require 'byebug'

require './variables'
require './modules/driver'
require './modules/driver_navigations'
require './modules/scrape_results'

# The class to process tiktok data.
class TikTokParser
  include Driver
  include DriverNavigations
  include ScrapeResults

  private

  # Collects user information for a chunk of users.
  #
  # @param names [Array<String>] Array of usernames to collect information for.
  # @param counter [Integer] Current count of collected user information.
  # @param number [Integer] Total number of user information to collect.
  # @return [Array<Array>] An array of user data, each represented as an array of values.
  def collect_info(names, counter, number)
    user_data = []

    names.each do |name|
      break if counter >= number

      user_url = "#{USER_URL}#{name}"
      sleep_time(NAVIGATION_SLEEP_TIME)
      user_data << [name, scrape_user_info(user_url)].flatten
      counter += 1
    end
    user_data
  end

  # Scrapes user data based on the specified query and number of users.
  #
  # @return [Array] An array of user data, each represented as an array of values.
  def scrape_user_info(user_url)
    # downloads 16 vids on every profile
    res = HTTParty.get(user_url)
    docs = Nokogiri::HTML(res.body)

    [
      find_user_subtitle(docs),
      find_following_amount(docs),
      find_followers_amount(docs),
      find_avg_views_num(docs),
      description = find_description(docs),
      find_email(description),
      find_socials(description)
    ]
  end

  # Finds the user subtitle for a user based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [String] The subtitle of a user.
  def find_user_subtitle(docs)
    docs.css('[data-e2e="user-subtitle"]').text
  end

  # Finds the number of followers for a user based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [String] The number of followers for the user.
  def find_followers_amount(docs)
    docs.css('[data-e2e="followers-count"]').text
  end

  # Finds the number of followings for a user based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [String] The number of followings for the user.
  def find_following_amount(docs)
    docs.css('[data-e2e="following-count"]').text
  end

  # Finds the average number of views for a user's videos based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [Float] The average number of views for the user's videos.
  def find_avg_views_num(docs)
    views = docs.css('[data-e2e="video-views"]').map(&:text)
    average_views = views.sum(&:to_f) / views.length unless views.empty?
    average_views&.round(2)
  end

  # Finds the average number of comments for a user's videos based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [Float] The average number of comments for the user's videos.
  # TODO: implement this
  def find_avg_comments_num(docs); end

  # Finds the description for a user based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the user's page.
  # @return [String] The description of the user's channel.
  def find_description(docs)
    docs.css('[data-e2e="user-bio"]').text
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
