class VisitedAirport < ApplicationRecord
  belongs_to :pilot
  belongs_to :airport

  validates :pilot, uniqueness: { scope: :airport }
end
