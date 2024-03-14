class Event < ApplicationRecord
  belongs_to :airport

  # TODO - Ask Alex for the kind of events
  enum :kind, { expo: 0, airshow: 1, flyin: 2, other: 3 }
  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }
  validates :image_link, presence: true
  validates :url, presence: true

  def kind_color
    case kind
    when 'expo'
      'primary'
    when 'airshow'
      'secondary'
    when 'flyin'
      'color4'
    when 'other'
      'color3'
    end
  end
end
