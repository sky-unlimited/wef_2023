class Event < ApplicationRecord
  belongs_to :airport

  # TODO - Ask Alex for the kind of events
  enum :kind, { expo: 0, airshow: 1, flyin: 2, other: 3 }
  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }
  validates :url, presence: true
  validates :title, uniqueness: { scope: [:start_date, :end_date, :airport_id, :kind], message: 'Event already exists' }

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

  def self.upcoming(airport: nil)
    events = self.where('start_date >= ?', Date.today)
    events = events.where(airport: airport) if airport
    events
  end

  def self.closest(airport)
    upcoming.sort_by { |event| [event.start_date, event.airport.geom_point.distance(airport.geom_point)] }
  end

  def one_day?
    start_date == end_date
  end
end
