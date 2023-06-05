require 'csv'

module AirportHelpers
  def csv_to_airport(row, factory, country)
    # RGeo point conversion
    point = factory.point(row['longitude_deg'].to_f, row['latitude_deg'].to_f)

    # We instanciate an airport from the csv row
    airport_hash = { icao: row['ident'], name: row['name'], city: row['municipality'], country: country, iata: row['iata_code'], latitude: row['latitude_deg'], longitude: row['longitude_deg'], altitude: row['elevation_ft'], airport_type: row['type'], url: row['home_link'], local_code: row['local_code'], lonlat: point }
  end
end


namespace :import do
  desc "Import airports from csv file"
  task airports: :environment do
    include AirportHelpers

    filepath = "ourairports-data/airports.csv"
    puts "Reading #{filepath}..."
    counter_rejected  = 0
    counter_updated   = 0
    counter_created   = 0

    # Variables setup
    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    country_list = WANDERBIRD_CONFIG['airport_countries_to_import']

    # Accepted countries
    puts "✈️  from #{country_list} are being imported:"
    puts "⏱️  Please wait..."
    
    # We iterate through the csv file
    CSV.foreach(filepath, headers: :first_row) do |row|

      # We retrieve the country id
      country = Country.find_by(code: row['iso_country'])

      # We check if airport country is white listed in wanderbird_config
      unless country_list.include?(Country.find(country.id).code)
        counter_rejected += 1
        next
      end
      
      # We check if current csv airport exists in database
      if Airport.find_by(icao: row['ident']).nil?
        # If NO we call an [CREATE]
        airport_hash = csv_to_airport(row, factory, country)
        airport = Airport.create(airport_hash)
        airport.persisted? ? counter_created += 1 : counter_rejected += 1
      else
        # If YES we call an [UPDATE]
        airport_hash = csv_to_airport(row, factory, country)
        airport = Airport.find_by(icao: row['ident'])
        airport.update(airport_hash)
        airport.persisted? ? counter_updated += 1 : counter_rejected += 1
      
      end


    end

    puts "✨ Created #{counter_created} / #{counter_created + counter_updated + counter_rejected} airports!"
    puts "✨ Updated #{counter_updated} / #{counter_created + counter_updated + counter_rejected} airports!"

  end
end
