class Pilot < ApplicationRecord
  belongs_to :user
  belongs_to :airport
  has_one :profile, dependent: :destroy
  has_one :preference, dependent: :destroy

  after_create :create_default_profile_and_preference

  enum airport_role: { staff: 0, pilot: 1, student: 2 }

  private

  def create_default_profile_and_preference
    Profile.create(pilot: self)
    Preference.create(pilot: self)
  end
end
