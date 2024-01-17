Rails.application.config.after_initialize do
  COUNT_ACCOMODATION  = PoiCatalogue.count(:accommodation)
  COUNT_FOOD          = PoiCatalogue.count(:food)
  COUNT_BUS_STATION   = PoiCatalogue.count(:bus_station)
  COUNT_BIKE_RENTAL   = PoiCatalogue.count(:bike_rental)
  COUNT_CAMP_SITE     = PoiCatalogue.count(:camp_site)
  COUNT_CAR_RENTAL    = PoiCatalogue.count(:car_rental)
end
