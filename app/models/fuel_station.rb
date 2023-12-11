require 'csv'

class FuelStation < ApplicationRecord
  belongs_to :airport

  #around_save :populate_audit_logs

  enum provider: { "Other" => 0, "Total Energies" => 1, "Air BP" => 2 } 
  enum status: { active: 0, unserviceable: 1, closed: 2 }
  # We prefix the methods name because rails generates conflicts in associated methods name
  # https://chat.openai.com/share/4edd4052-dc7a-4a64-acbc-33ceff8ee789
  enum fuel_avgas_100ll:  { "no" => 0, "yes" => 1, "automate" => 2 }, _prefix: :fuel_avgas_100ll
  enum fuel_avgas_91ul:   { "no" => 0, "yes" => 1, "automate" => 2 }, _prefix: :fuel_avgas_91ul
  enum fuel_mogas:        { "no" => 0, "yes" => 1, "automate" => 2 }, _prefix: :fuel_mogas
  enum charging_station:  { "no" => 0, "yes" => 1, "automate" => 2 }, _prefix: :charging_station
  
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP, allow_blank: true
  validates_format_of :phone, with: /\A(?:\+|00)[1-9][0-9 \-\(\)\.]{7,32}\z/, allow_blank: true # begin with "+" or "00" as we require international format

  validates :provider, presence: true
  validates :status, presence: true
  validates :airport_id, uniqueness: true

  def self.to_csv
    attributes = %w[id airport_id provider status fuel_avgas_100ll fuel_avgas_91ul fuel_mogas charging_station email phone]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |fuel_station|
        csv << fuel_station.attributes.values_at(*attributes)
      end
    end
  end

  def save_with_user(current_user, action)
    self.populate_audit_logs(current_user, self.id, action)
  end

  private

  def populate_audit_logs(current_user, target_id, action)
    record = AuditLog.new(user_id: current_user.id, target_id: target_id, target_type: :fuel_station, action: action) 
    record.save
  end

end