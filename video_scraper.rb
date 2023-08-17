require 'csv'
require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'
require 'byebug'

require './modules/driver'
require './modules/driver_navigations'
require './modules/scrape_results'
require 'parser'

# The class to process tiktok data.
class VideoParser
  include Driver
  include DriverNavigations
  include ScrapeResults

  private

  # Collects video information.
  #
  # @param names [Array<String>] Array of usernames to collect information for.
  # @param counter [Integer] Current count of collected user information.
  # @param number [Integer] Total number of user information to collect.
  # @return [Array<Array>] An array of video data, each represented as an array of values.
  def collect_info(names, counter, number)
    video_data = []

    names.each do |name|
      break if counter >= number

      user_url = "#{USER_URL}#{name}"
      sleep_time(NAVIGATION_SLEEP_TIME)
      video_data << [name, scrape_info(user_url)].flatten
      counter += 1
    end
    video_data
  end

  # Scrapes video data based on the specified query and number of users.
  #
  # @return [Array] An array of video data, each represented as an array of values.
  def scrape_info(user_url)
    @driver.navigate.to(user_url)
    video_ids = @driver.find_elements(css: '.eih2qak0').map { |el| el.attribute('href')[/\d+/] }

    video_data = []

    video_ids.each do |id|
      video_url = "#{user_url}/video/#{id}"
      res = HTTParty.get(video_url)
      docs = Nokogiri::HTML(res.body)

      video_data << [
        id,
        find_likes_num(docs),
        find_comments_num(docs),
        find_saved_num(docs)
      ]
    end
    video_data
  end

  # Finds the num of likes for a video based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the video page.
  # @return [String] The num of likes.
  def find_likes_num(docs)
    docs.css('[data-e2e="like-count"]').text
  end

  # Finds the num of comments for a video based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the video page.
  # @return [String] The num of comments.
  def find_comments_num(docs)
    docs.css('[data-e2e="comment-count"]').text
  end

  # Finds the num of saved for a video based on the provided Nokogiri document.
  #
  # @param docs [Nokogiri::HTML::Document] The Nokogiri document representing the video page.
  # @return [String] The num of saved.
  def find_saved_num(docs)
    docs.css('[data-e2e="undefined-count"]').text
  end
end
