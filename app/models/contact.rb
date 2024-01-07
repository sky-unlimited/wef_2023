class Contact < ApplicationRecord
  attr_accessor :request

  before_create :add_ip_address, unless: -> { Rails.env.test? }

  CATEGORIES = [  I18n.t('activerecord.attributes.contact.categories.other'),
                I18n.t('activerecord.attributes.contact.categories.privacy_policy'),
                I18n.t('activerecord.attributes.contact.categories.billing'),
                I18n.t('activerecord.attributes.contact.categories.problem'),
                I18n.t('activerecord.attributes.contact.categories.improvement'),
                I18n.t('activerecord.attributes.contact.categories.partnership') ]
  enum :category, { CATEGORIES[0] => 0,
                    CATEGORIES[1] => 10,
                    CATEGORIES[2] => 20,
                    CATEGORIES[3] => 30,
                    CATEGORIES[4] => 40,
                    CATEGORIES[5] => 50
                  }, _prefix: :category # OPTIMIZE: Improve this sentence, how to get ride of CATEGORIES constant?

  validates :email, presence: true
  validates :email, email: true
  #validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP  #not strict
  validates :accept_privacy_policy, acceptance: { message: I18n.t('subscribers.errors.accept_private_data_policy') }
  validates :description, presence: true, length: { minimum: 20 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :honey_bot, length: { is: 0 }
  #validates_format_of :phone, with: /\A(?:\+|00)[1-9][0-9 \-\(\)\.]{7,32}\z/, allow_blank: true # begin with "+" or "00" as we require international format, however a number like '+352661477661' doesn't validate. #TODO: Improve later the phone validation

  private

  def add_ip_address
    # Assuming your web server is behind a proxy like Nginx or Apache
    # Use request.headers["X-Forwarded-For"] to get the real IP address
    # If not using a proxy, you can use request.remote_ip directly
    self.ip_address = request.headers["X-Forwarded-For"] || request.remote_ip
  end
end
