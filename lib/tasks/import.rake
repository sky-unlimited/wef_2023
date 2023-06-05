require 'csv'

module ImportHelpers
  def csv_to_airport(row, factory, country)
    # RGeo point conversion
    point = factory.point(row['longitude_deg'].to_f, row['latitude_deg'].to_f)

    # We instanciate an airport from the csv row
    runway_hash = { icao: row['ident'], name: row['name'], city: row['municipality'], country: country, iata: row['iata_code'], latitude: row['latitude_deg'], longitude: row['longitude_deg'], altitude: row['elevation_ft'], airport_type: row['type'], url: row['home_link'], local_code: row['local_code'], lonlat: point }
  end

  def csv_to_runways(row, airport)
    # We instanciate a runway entry from the csv row
    airport_hash = { airport: airport, internal_id: row['id'], length_meter: (row['length_ft'].to_f * 0.3).to_i, width_meter: (row['width_ft'].to_f * 0.3).to_i, surface: row['surface'], le_ident: row['le_ident'], he_ident: row['he_ident'], le_heading_degT: row['le_heading_degT'], he_heading_degT: row['he_heading_degT'], lighted: row['lighted'] }
  end
end


namespace :import do
  desc "Import airports from csv file"
  task airports: :environment do
    include ImportHelpers

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

  desc "Import runways from csv file"
  task runways: :environment do
    include ImportHelpers

    filepath = "ourairports-data/runways.csv"
    puts "Reading #{filepath}..."
    counter_rejected  = 0
    counter_updated   = 0
    counter_created   = 0

    # Information about the process
    puts "⏱️  Runways will be imported, please wait..."
    
    # We iterate through the csv file
    CSV.foreach(filepath, headers: :first_row) do |row|
      # We first check that the airport is existing in our database
      if Airport.find_by(icao: row['airport_ident']).nil?
        # The runway info not needed for an import not in our database, we jump to next csv record
        counter_rejected += 1
        next
      end
        
      if Runway.find_by(internal_id: row['id']).nil?
        # If the internal_id does not exist we create a new record [INSERT]
        airport = Airport.find_by(icao: row['airport_ident'])
        runway_hash = csv_to_runways(row, airport)
        runway = Runway.create(runway_hash)
        runway.persisted? ? counter_created += 1 : counter_rejected += 1
      else
        # If the internal_id does exist, we update the existing record [UPDATE]
        airport = Airport.find_by(icao: row['airport_ident'])
        runway_hash = csv_to_runways(row, airport)
        runway = Runway.find_by(internal_id: row['id'])
        runway.update(runway_hash)
        runway.persisted? ? counter_updated += 1 : counter_rejected += 1
      end
    end

    puts "✨ Created #{counter_created} / #{counter_created + counter_updated + counter_rejected} runways!"
    puts "✨ Updated #{counter_updated} / #{counter_created + counter_updated + counter_rejected} runways!"

  end
end
