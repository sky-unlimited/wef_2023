class UpdatePilotCertificate < ActiveRecord::Migration[7.1]
  def up
    ultra_light_pilot = Certificate.find_by(name: "Ultra-light pilot")
    ultra_light_pilot = Certificate.create!(name: "Ultra-light pilot") if ultra_light_pilot.nil?
    private_pilot = Certificate.find_by(name: "Private pilot")
    private_pilot = Certificate.create!(name: "Private pilot") if private_pilot.nil?
    Preference.all.each do |preference|
      if preference.is_ultralight_pilot
        PilotCertificate.create!(pilot: preference.pilot, certificate: ultra_light_pilot)
      end
      if preference.is_private_pilot
        PilotCertificate.create!(pilot: preference.pilot, certificate: private_pilot)
      end
    end
  end

  def down
    PilotCertificate.destroy_all
  end
end
