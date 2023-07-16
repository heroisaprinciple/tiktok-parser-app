# frozen_string_literal: true

require './parser'

# The CSVGenerator class is responsible for generating CSV files.
class CSVGenerator
  def generate_csv(data)
    CSV.open('tiktok_data.csv', 'w+', write_headers: true,
             headers: [:Account, :Followers, :Avg_Views, :Channel_Desc, :Email, :Other_Accounts]) do |csv|
      data.each do |row|
        csv << row
      end
    end
  end

  def message_csv_creation
    puts 'CSV file is filled with data now!'
  end
end