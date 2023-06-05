class Airport < ApplicationRecord
  belongs_to :country
  has_many :runways

  ACCEPTED_AIRPORT_TYPES = [ "small_airport", "medium_airport", "large_airport" ].freeze

  validates :icao, presence: true
  validates :name, format: { without: /ET[A-Z]{2}/, message: "No German military airbase" }
  validates :name, format: { without: /(Air Base)/, message: "No French military airbase" }
  validates :airport_type, presence: true, inclusion: { in: ACCEPTED_AIRPORT_TYPES }

end
