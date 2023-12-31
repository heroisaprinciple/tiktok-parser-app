<h3> A console application for parsing tiktok info. </h3>

Run `bundle` to install all gems.

**To start, run the 'run_program' file with `ruby run_program.rb` You will be asked two things:**
1) The query.
2) The number of results you want to see.

That's all! Wait some seconds...
Then, all info will be saved in 'tiktok_user_data.csv' and 'tiktok_video_data.csv'.

When saved, you'll see <i>'CSV file is filled with data now!'</i> message in the console.

The main logic is in 'parser.rb'. There is documentation you can gladly follow.

'parser.rb' gets **user-related** data, while 'video_scraper.rb' gets **video-related** data.

<i>Account names can be repeated as I need a database to exclude the names I went through.
And the db is beyond this console application.</i>

**Important things I've learnt so far:**
1) Scraping elements by dynamic classes should be avoided at all costs. Yes, sometimes there is no way but doing this.
   But it is better to use more 'static' classes or `data-e2e`. These attributes are not related to the styling or
   functionality of the web page, making them less likely to change during development and updates.
2) Tiktok downloads new videos with scrolling. Selenium is a master for working with scrolling. Here, every 12 videos
   are downloaded.
3) Location can be a problem. If you run Selenium in the basic mode, you may be prompted for completing the captcha.
   And videos may not be downloaded because of it. The same in headless mode, except you can't see that.
   To see what is your page response, do `@driver.page_source(url)`.
   Then, parse the page source with Nokogiri or other methods to extract information. Use VPN or proxy servers. 
