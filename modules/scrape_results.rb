module ScrapeResults
  # Scrapes user data.
  #
  # @param number [Integer] The number of queries to search for on TikTok.
  # @return [Array<Array>] An array of user data, each represented as an array of values.
  def scrape_search_results(number)
    data = []
    counter = 0

    loop do
      if (counter % 12).zero?
        scroll_to_bottom
        sleep_time(NAVIGATION_SLEEP_TIME)
        names = @driver.find_elements(css: '[data-e2e="search-card-user-unique-id"]').map(&:text)
      end

      chunked_names = names.slice(counter, names.length)
      user_data = collect_info(chunked_names, counter, number)
      data.concat(user_data)
      counter += user_data.length
      break if counter >= number
    end
    @driver.quit
    data
  end

  # Scrapes user data based on the specified query and number of queries wanted to display.
  #
  # @param query [String] The query to search for on TikTok.
  # @param number [Integer] The number of queries.
  def scrape_data(query, number)
    navigate_to_main_page(query)
    scrape_search_results(number)
  end
end
