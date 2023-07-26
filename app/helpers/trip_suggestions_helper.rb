module TripSuggestionsHelper
  def winds_ms_to_kts(wind_ms)
    (wind_ms * 1.9438445).round(0)
  end
end
