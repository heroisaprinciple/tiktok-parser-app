# frozen_string_literal: true

require './parser'
require './video_scraper'

# The CSVGenerator class is responsible for generating CSV files.
class CSVGenerator
  def generate_csv_for_user(data)
    CSV.open('csv_files/tiktok_user_data.csv', 'w+', write_headers: true,
             headers:
               [:Account, :User_Subtitle, :Following,
                :Followers, :Avg_Views, :Channel_Desc,
                :Email, :Other_Accounts
               ]) do |csv|
      data.each do |row|
        csv << row
      end
    end
  end

  def generate_csv_for_video(data)
    CSV.open('csv_files/tiktok_video_data.csv', 'w+', write_headers: true,
             headers:
               [:Account, :ID, :Likes,
                :Comments_Number, :Saved_Times
               ]) do |csv|
      data.each do |row|
        csv << row
      end
    end
  end

  def message_csv_creation
    puts 'CSV file is filled with data now!'
  end
end
