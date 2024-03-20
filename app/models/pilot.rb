class Pilot < ApplicationRecord
  belongs_to :user
  belongs_to :airport
  has_one :preference, dependent: :destroy
  has_many :pilot_certificates, dependent: :destroy
  has_many :certificates, through: :pilot_certificates

  after_create :create_default_preference

  enum airport_role: { staff: 0, pilot: 1, student: 2 }

  validates :user, presence: true, uniqueness: true

  private

  def create_default_preference
    Preference.create(pilot: self)
  end
end
