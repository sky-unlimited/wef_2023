class Airport < ApplicationRecord
  belongs_to :country
  has_many :runways

  validates :icao, uniqueness: true
  validates :local_code, uniqueness: true

  ACCEPTED_AIRPORT_TYPES = [ "small_airport", "medium_airport", "large_airport" ].freeze

  validates :icao, presence: true
  validates :longitude, presence: true
  validates :latitude, presence: true
  validates :airport_type, presence: true, inclusion: { in: ACCEPTED_AIRPORT_TYPES }
  validate :filter_airports

  def filter_airports
    # We load white list from config file
    white_list = WANDERBIRD_CONFIG['airports_white_list']

    # We check if airport is white listed
    return if white_list.include?(icao)

    # We check if airport should be filtered or not
    errors.add("Airport filter", "DE MIL Airports are not taken in scope") if icao.match?(/ET[A-Z]{2}/) # MIL DE
    errors.add("Airport filter", "FR MIL Airports are not taken in scope") if name.match?(/(Air Base)/) # MIL FR

  end
end
