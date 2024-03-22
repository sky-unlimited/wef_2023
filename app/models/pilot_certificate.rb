class PilotCertificate < ApplicationRecord
  belongs_to :pilot
  belongs_to :certificate

  validates :pilot, uniqueness: { scope: :certificate }
end
