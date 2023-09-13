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
      "#{I18n.t('date.days', count: day_offset)}"
    end
  end

  def poi_count_groups(destination_airport, trip_request)
    PoiCatalogue.count_groups_per_airport(destination_airport)
  end

  def get_group_icon(group)
    data = {
    :food => "🍔",
    :beverage => "🥤",
    :fuel_car => "⛽",
    :fuel_plane => "✈️",
    :bike_rental => "🚲",
    :car_rental => "🚗",
    :camp_site => "⛺",
    :accommodation => "🏨",
    :shop => "🛒",
    :bus_station => "🚌",
    :train_station => "🚆"
    }

    # Check if the provided key exists in the data hash
    if data.key?(group)
      return data[group]
    else
      return "?"
    end  
  end
end
