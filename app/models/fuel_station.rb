require 'csv'

class FuelStation < ApplicationRecord
  belongs_to :airport

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

  @@inventory = {
    :fuel_types => {
      :fuel_avgas_100ll =>  {:icon => "fuel_100ll.png" },
      :fuel_avgas_91ul  =>  {:icon => "fuel_91ul.png" },
      :fuel_mogas       =>  {:icon => "fuel_mogas.png" },
      :charging_station =>  {:icon => "power.png" }
    },
    :fuel_providers => {
      :other          => {:icon => "fuel.png" },
      :total_energies => {:icon => "logo_total_small.png" },
      :air_bp         => {:icon => "logo_airbp_small.png" }
    }
  }

  def self.inventory
    @@inventory
  end

  def self.to_csv
    attributes = %w[id airport_id provider status fuel_avgas_100ll fuel_avgas_91ul fuel_mogas charging_station email phone]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |fuel_station|
        csv << fuel_station.attributes.values_at(*attributes)
      end
    end
  end

  def save_with_user(current_user, action, request)
    self.populate_audit_logs(current_user, self.id, action, request)
  end

  private

  def populate_audit_logs(current_user, target_id, action, request)
    ip_address = request.headers["X-Forwarded-For"] || request.remote_ip
    record = AuditLog.new(user_id: current_user.id, target_id: target_id, target_type: :fuel_station, action: action, ip_address: ip_address) 
    record.save
  end

end
