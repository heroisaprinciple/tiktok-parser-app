require 'open-uri'
require 'nokogiri'
require 'httparty'
require 'byebug'
require 'csv'

# for one (the main) page
def scrape_books_for_main
  url = 'https://books.toscrape.com/'

  response = HTTParty.get(url)
  if response.code == 200
    puts "Alright!"
  else
    puts "Error: #{response.code}"
    exit
  end

  doc = Nokogiri::HTML(response.body)
  all_book_containers = doc.css('article.product_pod')
  books = []

  all_book_containers.each do |container|
    title = container.css('h3 a').first['title']
    price = container.css('p.price_color').text.delete('£').to_f
    rating = container.css('i.icon-star').count
    availability = container.css('.availability').text.strip
    books << [title, price, rating, availability]
  end

  books
end

# p(scrape_books_for_main)


# scrape books for all pages
def scrape_for_all_pages
  url = "https://books.toscrape.com"
  res = HTTParty.get(url)
  pages_total = Nokogiri::HTML(res.body).css('.current').text.strip.scan(/\d+/)[1].to_i
  p(pages_total)
  books = []

  CSV.open(
    'books.csv',
    'w+',
    write_headers: true,
    headers: %w[Title Price Rating Availability]
  ) do |csv|
    pages_total.times do |i|
      response = HTTParty.get(url + "/catalogue/page-#{i + 1}.html")
  
      doc = Nokogiri::HTML(response.body)
      all_book_containers = doc.css('article.product_pod')
      all_book_containers.each do |container|
        title = container.css('h3 a').first['title']
        price = container.css('p.price_color').text.delete('£').to_f
        rating = container.css('i.icon-star').count
        availability = container.css('.availability').text.strip
        books << [title, price, rating, availability]
        csv << books
      end
    end
  end
end

p(scrape_for_all_pages)