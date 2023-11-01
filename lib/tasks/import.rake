require 'csv'

module ImportHelpers
  def csv_to_airport(row, factory, country)
    # RGeo point conversion
    point = factory.point(row['longitude_deg'].to_f, row['latitude_deg'].to_f)

    # We instanciate an airport from the csv row
    airport_hash = { icao: row['ident'], name: row['name'], city: row['municipality'], country: country, iata: row['iata_code'], latitude: row['latitude_deg'], longitude: row['longitude_deg'], altitude: row['elevation_ft'], airport_type: row['type'], url: row['home_link'], local_code: row['local_code'], lonlat: point }
  end

  def csv_to_runways(row, airport)
    # We instanciate a runway entry from the csv row
    runway_hash = { airport: airport, internal_id: row['id'], length_meter: (row['length_ft'].to_f * 0.3).to_i, width_meter: (row['width_ft'].to_f * 0.3).to_i, surface: row['surface'], le_ident: row['le_ident'], he_ident: row['he_ident'], le_heading_degT: row['le_heading_degT'], he_heading_degT: row['he_heading_degT'], lighted: row['lighted'] }
  end
end

namespace :import do
  desc "Import countries from csv file"
  task countries: :environment do
    filepath = "ourairports-data/countries.csv"
    puts "⏱️  Reading #{filepath}. Please wait..."
    counter_created = 0
    counter_rejected = 0
    CSV.foreach(filepath, headers: :first_row) do |row|
      country = Country.create(code: row['code'], name: row['name'], continent: row['continent'])
      country.persisted? ? counter_created += 1 : counter_rejected += 1
    end
    puts "✨ #{counter_created} / #{counter_created + counter_rejected} countries created!"
  end

  desc "Import airports from csv file"
  task airports: :environment do
    include ImportHelpers

    filepath = "ourairports-data/airports.csv"
    puts "Reading #{filepath}..."
    counter_rejected  = 0
    counter_updated   = 0
    counter_created   = 0
    counter_existing  = 0

    # Variables setup
    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    country_list = WEF_CONFIG['airport_countries_to_import']

    # Accepted countries
    puts "✈️  from #{country_list} are being imported:"
    puts "⏱️  Please wait..."
    
    # We iterate through the csv file
    CSV.foreach(filepath, headers: :first_row) do |row|

      # We retrieve the country id
      country = Country.find_by(code: row['iso_country'])

      # We check if airport country is white listed in WEF_CONFIG
      unless country_list.include?(Country.find(country.id).code)
        counter_rejected += 1
        next
      end
      
      # We check if current csv airport exists in database
      airport_csv_hash = csv_to_airport(row, factory, country)

      airport_db  = Airport.find_by(icao: row['ident'])
      if airport_db.nil?  # [CREATE]
        airport_csv = Airport.create(airport_csv_hash)
        airport_csv.persisted? ? counter_created += 1 : counter_rejected += 1
      else                # [UPDATE]
        counter_existing += 1
        # We create a temporary airport instance from csv
        airport_csv = Airport.new(airport_csv_hash)
        # Objects cannot be compared as some values are always different (id, created_at, updated_at)
        attributes_csv  = airport_csv.attributes
        attributes_db   = airport_db.attributes
        # Check for differences and update only if something has changed
        differences = {}
        excluded_attributes = ["id", "created_at", "updated_at"]
        attributes_csv.each do |key, value|
          unless excluded_attributes.include?(key)
            if value != attributes_db[key]
              differences[key] = value
            end
          end
        end
        if differences.any?
          # Check if the updated data is valid
          airport_db.assign_attributes(differences)
          if airport_db.valid?
            airport_db.update(differences)
            if airport_db.persisted?
              counter_updated += 1
              puts "#{airport_db.icao} - #{airport_db.name} has been updated with #{differences}!"
            else
              puts "#{airport_db.icao} - #{airport_db.name} update has failed!"
            end
          else
            # Provide explanation on failed validation
            puts "Validation failed for #{airport_db.icao} - #{airport_db.name}. Update was not performed."
            airport_db.errors.full_messages.each do |attribute, message|
              puts "Validation error on #{attribute}: #{message}"
            end
            # If validation rule no more passes, we deactivate the airport
            airport_to_deactivate = Airport.find(airport_db.id)
            if airport_to_deactivate.actif == true # If on last update it has already been deactivated, no need to mention
              airport_to_deactivate.update(actif: false)
              puts "⚠️  Airport #{airport_to_deactivate.id} - #{airport_to_deactivate.icao} has been deactivated from WEF"
            end
          end
        end
      end
    end
    puts "✨ Created #{counter_created} / #{counter_created + counter_updated + counter_rejected} airports!"
    puts "✨ Updated #{counter_updated} / #{counter_existing} airports!"
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
