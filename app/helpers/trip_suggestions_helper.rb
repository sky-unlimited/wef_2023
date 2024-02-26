# Manages methods for the trip_suggestions view
module TripSuggestionsHelper
  def winds_ms_to_kts(wind_ms)
    (wind_ms * 1.9438445).round(0)
  end

  def format_offset_date_human(day_offset)
    day_offset = day_offset.to_i
    case day_offset
    when 0
      I18n.t('date.today')
    when 1
      I18n.t('date.tomorrow')
    else
      I18n.t('date.days', count: day_offset).to_s
    end
  end

  def format_time(time_in_minutes)
    if time_in_minutes < 60
      "#{time_in_minutes} min"
    else
      hours = time_in_minutes / 60
      minutes = time_in_minutes % 60
      time_str = "#{hours}h"
      time_str += " #{minutes}min" if minutes.positive?
      time_str
    end
  end

  def get_airport_poi_icons(airport)
    icons_array = []
    groups = PoiCatalogue.count_groups_per_airport(airport)
    groups.each_key do |key|
      icons_array << PoiCatalogue.inventory[key]['icon']
    end
    icons_array
  end

  def get_trip_request_fuel_stations_icons(_airport)
    array = []
    if @trip_request.fuel_station_100ll
      array << FuelStation.inventory[:fuel_types][:fuel_avgas_100ll][:icon]
    end
    if @trip_request.fuel_station_91ul
      array << FuelStation.inventory[:fuel_types][:fuel_avgas_91ul][:icon]
    end
    if @trip_request.fuel_station_mogas
      array << FuelStation.inventory[:fuel_types][:fuel_mogas][:icon]
    end
    if @trip_request.charging_station
      array << FuelStation.inventory[:fuel_types][:charging_station][:icon]
    end
    array
  end
end
