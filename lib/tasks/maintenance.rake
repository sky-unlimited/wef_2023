require 'csv'

namespace :maintenance do
  desc "Populate new ourairports_id column with the airport id provided by our-airports"
  task update_ourairports_id: :environment do
    filepath = "ourairports-data/airports.csv"
    puts "Updating ourairports_id column with our-airports airport id..."
    counter = 0
    CSV.foreach(filepath, headers: :first_row) do |row|
      airport = Airport.find_by(icao: row['ident'])
      unless airport.nil?
        airport.update(ourairports_id: row['id']) unless airport.nil?
        counter += 1
      end
    end
    puts "Updated #{counter} records!"
  end
end
