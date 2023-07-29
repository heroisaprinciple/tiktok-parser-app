<h3> A console application for parsing tiktok info made within 4 days. </h3>

To start, run the 'run_program' file. You will be asked two things:
1) The query.
2) The number of results you want to see.

That's all! Wait some seconds...
Then, all info will be saved in 'tiktok_data.csv'.

The main logic is in 'parser.rb'. There is a documentation you can gladly follow.

**Important things I've learnt so far:**
1) Scraping elements by dynamic classes should be avoided at all costs. Yes, sometimes there is no way but doing this.
But it is better to use more 'static' classes or data-e2e. These attributes are not related to the styling or
functionality of the web page, making them less likely to change during development and updates.
