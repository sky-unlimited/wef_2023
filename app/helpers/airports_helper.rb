module AirportsHelper
  def extract_time_from_date(date)
    return date.strftime('%H:%M')
  end
end
