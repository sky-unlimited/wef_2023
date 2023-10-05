class Airport < ApplicationRecord
  belongs_to :country
  has_many :runways
  has_many :trip_requests, dependent: :destroy
  has_many :pilot_prefs

  ACCEPTED_AIRPORT_TYPES = WEF_CONFIG['airport_types_to_import']

  validates :icao, presence: true, uniqueness: true
  validates :longitude, presence: true
  validates :latitude, presence: true
  validates :airport_type, presence: true, inclusion: { in: ACCEPTED_AIRPORT_TYPES }
  validate :filter_airports

  def filter_airports
    # We load white list from config file
    white_list = WEF_CONFIG['airports_white_list']

    # We check if airport is white listed
    return if white_list.include?(icao)

    # We check if airport should be filtered or not
    # General military airports
    errors.add("Airport filter", "ALL MIL Airports are out of scope") if name.match?(/(Air Base)/i)

    # General glider fields
    errors.add("Airport filter", "Glider fields are out of scope") if name.match?(/(Glider)/i)

    # Germany
    errors.add("Airport filter", "DE MIL Airport are out of scope") if icao.match?(/ET[A-Z]{2}/)

    # Netherlands
    exclusion_nl = ['EHDL','EHEH','EHGR','EHLW','EHVB','EHMC','EHML','EHSB','EHVK','EHDP','EHWO'] 
    errors.add("Airport filter", "NL MIL Airport are out of scope") if exclusion_nl.include?(icao)
    exclusion_nl = ['EHAM']
    errors.add("Airport filter", "NL Airport not suitable for GA") if exclusion_nl.include?(icao)

    # Denmark
    exclusion_dk = ['EKYT','EKKA','EKSP']
    errors.add("Airport filter", "DK MIL Airport are out of scope") if exclusion_dk.include?(icao)
  end
end
