# Helper to display info on airports view
module AirportsHelper
  def extract_time_from_date(date)
    date.strftime('%H:%M')
  end

  def display_fuel_provider_logo(airport)
    case airport.fuel_station.provider
    when FuelStation.providers.keys[1]
      FuelStation.inventory[:fuel_providers][:total_energies][:icon]
    when FuelStation.providers.keys[2]
      FuelStation.inventory[:fuel_providers][:air_bp][:icon]
    else
      FuelStation.inventory[:fuel_providers][:other][:icon]
    end
  end

  # Should be deprecated
  def airport_fuel_types_icons(airport)
    fuel_type_icons = []
    unless airport.fuel_station.nil?
      if airport.fuel_station.fuel_avgas_100ll != 'no'
        fuel_type_icons << FuelStation
                           .inventory[:fuel_types][:fuel_avgas_100ll][:icon]
      end
      if airport.fuel_station.fuel_avgas_91ul != 'no'
        fuel_type_icons << FuelStation
                           .inventory[:fuel_types][:fuel_avgas_91ul][:icon]
      end
      if airport.fuel_station.fuel_mogas != 'no'
        fuel_type_icons << FuelStation
                           .inventory[:fuel_types][:fuel_mogas][:icon]
      end
      if airport.fuel_station.charging_station != 'no'
        fuel_type_icons << FuelStation.inventory[:fuel_types]
        [:charging_station][:icon]
      end
    end
    fuel_type_icons
  end

  def display_poi_label(key)
    label = PoiCatalogue.inventory[key]['label']
    I18n.t("activerecord.attributes.trip_request.#{label}")
  end
end
