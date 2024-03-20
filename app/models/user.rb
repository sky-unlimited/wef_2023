# This class mananges basic user information
class User < ApplicationRecord
  has_one :pilot_pref, dependent: :destroy # TODO: Remove this line after migration

  has_one :pilot, dependent: :destroy
  has_one :preference, through: :pilot, dependent: :destroy
  has_one :profile, through: :pilot, dependent: :destroy

  has_many :trip_requests, dependent: :destroy
  has_one_attached :picture do |attachable|
    attachable.variant :thumb, resize_to_limit: [48, 48]
  end

  # Remainings timeoutable :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable
  enum role: %i[user admin]
  after_initialize :set_default_role, if: :new_record?
  after_save :create_default_pilot
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validate :picture_format
  validate :password_complexity

  def base_airport
    pilot.airport
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def picture_format
    return unless picture.attached?

    if picture.blob.content_type.start_with? 'image/'
      if picture.blob.byte_size > 2.megabytes
        errors.add(:picture, I18n.t('users.errors.image_size'))
        picture.purge
      end
    else
      picture.purge
      errors.add(:picture, I18n.t('users.errors.file_type'))
    end
  end

  def create_default_pilot
    return unless pilot.nil?

    Pilot.create(
      user: self,
      airport: Airport.find_by(icao: 'ELLX')
    )
  end

  def password_complexity
    if password.present? &&
      !password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/)
      errors.add(:password, I18n.t('users.errors.password_policy'))
    end
  end
end
