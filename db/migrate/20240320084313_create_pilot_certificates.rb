class CreatePilotCertificates < ActiveRecord::Migration[7.1]
  def change
    create_table :pilot_certificates do |t|
      t.references :pilot, null: false, foreign_key: true
      t.references :certificate, null: false, foreign_key: true

      t.timestamps
    end
  end
end
