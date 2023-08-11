module Driver
  def initialize
    @driver = create_driver
  end

  def create_driver
    options = Selenium::WebDriver::Options.chrome
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--incognito')
    options.add_argument('--headless')
    options.add_argument('--window-size=1920,1080')

    Selenium::WebDriver.for :chrome, options: options
  end
end
