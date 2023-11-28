class FuelStation < ApplicationRecord
  belongs_to :airport

  enum provider: { "Other" => 0, "Total Energies" => 1, "Air BP" => 2 } 
  enum status: { active: 0, unserviceable: 1, closed: 2 }
  
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP, allow_nil: true
  validates_format_of :phone, with: /\A(?:\+|00)[1-9][0-9 \-\(\)\.]{7,32}\z/, allow_nil: true # begin with "+" or "00" as we require international format

  validates :provider, presence: true
  validates :status, presence: true
  validates :airport_id, uniqueness: true

end
