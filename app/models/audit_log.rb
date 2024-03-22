# This class is only intended to record registered users interactions
# with several objects like fuel_stations updates, fuel_prices, etc...
class AuditLog < ApplicationRecord
  belongs_to :user

  enum :action, { "created" => 0, "updated" => 1}
  enum :target_controller, { "fuel_stations" => 0 , "contacts" => 1, "followers" => 2 }

  validates :user, presence: true
  validates :target_id, presence: true
  validates :target_controller, presence: true
  validates :action, presence: true
end
