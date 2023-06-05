class Country < ApplicationRecord
  has_many :airports

  CONTINENTS = ["NA", "SA", "AF", "EU", "AN", "AS", "OC"].freeze

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :continent, presence: true, inclusion: { in: CONTINENTS }

  validates_length_of :code, is: 2
  validates_length_of :continent, is: 2

end
