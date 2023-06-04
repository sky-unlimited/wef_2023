require 'csv'

namespace :import do
  # ---------------- AIRPORTS -------------------
  # ---------------------------------------------
  desc "Import airports from csv file"
  task airports: :environment do
    filepath = "ourairports-data/airports.csv"
    puts "Reading #{filepath}..."
    counter_rejected  = 0
    counter_updated   = 0
    counter_created   = 0

    # First we check if it is a first import
    if Airport.count.zero? # No airports yet, [insert] mode
      puts "First airport database import..."
      factory = RGeo::Geographic.spherical_factory(srid: 4326)

      CSV.foreach(filepath, headers: :first_row) do |row|
        # RGeo point conversion
        point = factory.point(row['longitude_deg'].to_f, row['latitude_deg'].to_f)

        # We retrieve the country id
        country = Country.find_by(code: row['iso_country'])

        # We check if current airport country is permitted for import
        country_list = WANDERBIRD_CONFIG['airport_countries_to_import']
        unless country_list.include?(Country.find(country.id).code)
          counter_rejected += 1
          next
        end

        airport = Airport.create(icao: row['ident'], name: row['name'], city: row['municipality'], country: country, iata: row['iata_code'], latitude: row['latitude_deg'], longitude: row['longitude_deg'], altitude: row['elevation_ft'], airport_type: row['type'], url: row['home_link'], local_code: row['local_code'], lonlat: point)
        airport.persisted? ? counter_created += 1 : counter_rejected += 1
      end
      puts "Imported #{counter_created} / #{counter_created + counter_rejected} airports!"
    else
      # A first import has been done, [update] mode
      puts "Airport database existing..."
      CSV.foreach(filepath, headers: :first_row) do |row|
        # We test if the airport is existing in database
        if Airport.find_by(icao: row['ident']).nil? # Airport doesn't exist -> [insert] mode
          airport = Airport.create(icao: row['ident'], name: row['name'], city: row['municipality'], country: country_id, iata: row['iata_code'], latitude: row['latitude_deg'], longitude: row['longitude_deg'], altitude: row['elevation_ft'], airport_type: row['type'], url: row['home_link'], local_code: row['local_code'])
          airport.persisted? ? counter_created += 1 : counter_rejected += 1
        else  # Airports already exists -> [update] mode
          airport = Airport.find_by(icao: row['ident'])
          airport.update(icao: row['ident'], name: row['name'], city: row['municipality'], country: country_id, iata: row['iata_code'], latitude: row['latitude_deg'], longitude: row['longitude_deg'], altitude: row['elevation_ft'], airport_type: row['type'], url: row['home_link'], local_code: row['local_code'])
          airport.persisted? ? counter_updated += 1 : counter_rejected += 1
        end
      end
      puts "Created #{counter_created} / #{counter_created + counter_rejected} airports!"
      puts "Updated #{counter_updated} / #{counter_updated + counter_rejected} airports!"
    end
  end
end
