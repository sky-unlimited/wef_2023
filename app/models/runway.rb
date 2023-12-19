class Runway < ApplicationRecord
  belongs_to :airport

  validates :surface, presence: true
  validates :length_meter, numericality: { greater_than: 0 }
end
