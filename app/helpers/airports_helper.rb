module AirportsHelper
  def extract_time_from_date(date)
    return date.strftime('%H:%M')
  end

  def display_fuel_provider_logo(airport)
    case airport.fuel_station.provider
    when FuelStation.providers.keys[1]
      logo = FuelStation.inventory[:fuel_providers][:total_energies][:icon]
    when FuelStation.providers.keys[2]
      logo = FuelStation.inventory[:fuel_providers][:air_bp][:icon]
    else
      logo = FuelStation.inventory[:fuel_providers][:other][:icon]
    end
    return logo
  end

  def airport_fuel_types_icons(airport)
    fuel_type_icons = []
    unless airport.fuel_station.nil?
      fuel_type_icons << FuelStation.inventory[:fuel_types][:fuel_avgas_100ll][:icon] if airport.fuel_station.fuel_avgas_100ll != "no"
      fuel_type_icons << FuelStation.inventory[:fuel_types][:fuel_avgas_91ul][:icon] if airport.fuel_station.fuel_avgas_91ul != "no"
      fuel_type_icons << FuelStation.inventory[:fuel_types][:fuel_mogas][:icon] if airport.fuel_station.fuel_mogas != "no"
      fuel_type_icons << FuelStation.inventory[:fuel_types][:charging_station][:icon] if airport.fuel_station.charging_station != "no"
    end
    return fuel_type_icons
  end
end
