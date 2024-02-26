# Manages the airports and validation rules
#   Airports database provided by ourairports.com
#   Airports are loaded with db:seed
#   and updated with rake airports:import
class Airport < ApplicationRecord
  belongs_to :country
  has_many :runways
  has_many :trip_requests, dependent: :destroy
  has_one :pilot_pref
  has_one :fuel_station

  ACCEPTED_AIRPORT_TYPES = WEF_CONFIG['airport_types_to_import']

  validates :icao, presence: true, uniqueness: true
  validates :longitude, presence: true
  validates :latitude, presence: true
  validates :airport_type, presence: true,
                           inclusion: { in: ACCEPTED_AIRPORT_TYPES }
  validate :filter_airports

  def filter_airports
    # We load white list from config file
    white_list = WEF_CONFIG['airports_white_list']

    # We check if airport is white listed
    return if white_list.include?(icao)

    # We check if airport should be filtered or not
    # General MIL airports
    if name.match?(/(Air Base)/i)
      errors.add('Airport filter',
                 'ALL MIL Airports are out of scope')
    end

    # General glider fields
    if name.match?(/(Glider)/i)
      errors.add('Airport filter',
                 'Glider fields are out of scope')
    end

    # German MIL airports
    return unless icao.match?(/ET[A-Z]{2}/)

    errors.add('Airport filter',
               'DE MIL Airport are out of scope')
  end
end
