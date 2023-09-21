module TripRequestsHelper
  def displayIconAndLabel(group)
    "#{PoiCatalogue.inventory[group][:icon]} #{PoiCatalogue.inventory[group][:label]}"
  end
end
