require 'csv'

class Subscriber < ApplicationRecord
  attr_accessor :request

  before_create :add_unsubscribe_hash
  #before_validation :add_ip_address
  before_validation :add_ip_address, unless: -> { Rails.env.test? }
  before_validation :check_timelapse_before_last_attempt, on: :create, unless: -> { Rails.env.test? }

  validates :email, presence: true, uniqueness: true
  #validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP  #not strict
  validates :email, email: true
  validates :accept_private_data_policy, acceptance: { message: I18n.t('subscribers.errors.accept_private_data_policy') }

  def self.to_csv
    attributes = %w[id email created_at]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |contact|
        csv << contact.attributes.values_at(*attributes)
      end
    end
  end

  private

  def add_unsubscribe_hash
    self.unsubscribe_hash = SecureRandom.hex
  end

  def add_ip_address
    # Assuming your web server is behind a proxy like Nginx or Apache
    # Use request.headers["X-Forwarded-For"] to get the real IP address
    # If not using a proxy, you can use request.remote_ip directly
    self.ip_address = request.headers["X-Forwarded-For"] || request.remote_ip
  end

  def check_timelapse_before_last_attempt
    # In order to prevent mass injections, we ensure that for the same last ip_address
    # a period of 30 seconds has elapsed
    last_attempt = Subscriber.where(ip_address: ip_address).order(created_at: :desc).first

    if last_attempt && (Time.current - last_attempt.created_at) < 30.seconds
      errors.add(:created_at, "Too many attempts. Please wait before trying again.")
    end
  end
end
