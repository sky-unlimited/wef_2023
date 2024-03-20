class Certificate < ApplicationRecord
  has_many :pilot_certificates
  has_many :pilots, through: :pilot_certificates

  validates :name, presence: true, uniqueness: true
end
