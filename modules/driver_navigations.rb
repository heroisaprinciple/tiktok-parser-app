require './variables'

module DriverNavigations
  URL = 'https://www.tiktok.com/search?q='
  SCROLL_SLEEP_TIME = 2
  NAVIGATION_SLEEP_TIME = 3
  
  def sleep_time(seconds)
    sleep(seconds)
  end

  def scroll_to_bottom
    @driver.execute_script('window.scrollTo(0, document.body.scrollHeight);')
    sleep_time(SCROLL_SLEEP_TIME)
  end

  def navigate_to_main_page(query)
    timestamp = (Time.now.to_f * 1000).to_i
    url = query.include?('#') ? "#{URL}#{query.gsub('#', '')}&=#{timestamp}" : "#{URL}#{query}&t=#{timestamp}"
    @driver.navigate.to(url)
    sleep_time(NAVIGATION_SLEEP_TIME)
  end
end
