class User < ApplicationRecord
  has_one :pilot_pref, dependent: :destroy
  has_many :trip_requests, dependent: :destroy
  has_one_attached :picture do | attachable |
    attachable.variant :thumb, resize_to_fill: [ 48, 48 ]
  end

# Remainings timeoutable :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable
  enum role: [ :user, :admin ]
  after_initialize :set_default_role, if: :new_record?
  after_save :create_default_pilot_preferences
  validates :last_name, presence: true
  validates :first_name, presence: true
  validate :picture_format

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

  def create_default_pilot_preferences
    if self.pilot_pref.nil?
      pilot_pref = PilotPref.create(
        user_id: self.id,
        is_private_pilot: true,
        airport_id: Airport.find_by(icao: "ELLX").id
      )
    end
  end

end
