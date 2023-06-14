class TripRequest < ApplicationRecord
  belongs_to :user
  belongs_to :airport

  enum trip_mode: [ :events, :suggested, :custom ]
  validates :trip_mode, inclusion: { in: trip_modes.keys }
  validates :end_date, comparison: { greater_than_or_equal_to: :start_date }, unless: :end_date_not_null?
  validate :start_date_cannot_be_in_the_past

  private

  def end_date_not_null?
    end_date.nil?
  end

  def start_date_cannot_be_in_the_past
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "can't be in the past")
    end
  end
end
