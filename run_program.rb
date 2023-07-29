# frozen_string_literal: true

require './parser'
require './csv_generator'

def process_tiktok_data
  puts 'Enter the query to use. In essence, #enrique or ruby: '
  query = gets.chomp
  puts 'Enter the number of queries you want to be shown. In essence, 10: '
  number = gets.chomp.to_i
  puts 'Please, wait some seconds for us to proceed.'

  scraper = TikTokParser.new
  data = scraper.scrape_data(query, number)

  csv_generator = CSVGenerator.new
  csv_generator.generate_csv(data)
  csv_generator.message_csv_creation
end

process_tiktok_data
