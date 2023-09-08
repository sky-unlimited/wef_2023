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

  def poi_group_to_icon(destination_airport, trip_request)
    PoiCatalogue.count_groups_per_airport(destination_airport)
  end

end
