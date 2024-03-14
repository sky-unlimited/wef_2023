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

  def self.upcoming
    where('start_date >= ?', Date.today)
  end

  def self.closest(airport)
    upcoming.sort_by { |event| [event.airport.geom_point.distance(airport.geom_point), event.start_date] }
  end

  def one_day?
    start_date == end_date
  end
end
