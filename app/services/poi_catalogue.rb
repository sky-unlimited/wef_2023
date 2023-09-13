class PoiCatalogue
  @@inventory = {
    :food => {
        :categories => ["amenity"],
        :amenities => ["restaurant", "fast_food"]},
    :beverage => {
        :categories => ["amenity"],
        :amenities => ["bar", "cafe"]},
    :fuel_car => {
        :categories => ["amenity"],
        :amenities => ["fuel"]},
    :fuel_plane => {
        :categories => ["aeroway"],
        :amenities => ["fuel"]},
    :bike_rental => {
        :categories => ["amenity"],
        :amenities => ["bicycle_rental"]},
    :car_rental => {
        :categories => ["amenity"],
        :amenities => ["car_rental"]},
    :camp_site => {
        :categories => ["tourism"],
        :amenities => ["camp_site", "bivouac_site"]},
    :accommodation => {
        :categories => ["tourism"],
        :amenities => ["hotel","chalet","guest_house","Gîte","hostel","motel"]},
    :shop => {
        :categories => ["shop"],
        :amenities => ["bakery", "supermarket"]},
    :bus_station => {
        :categories => ["highway", "amenity"],  #most are in highway
        :amenities => ["bus_station", "bus_stop"]},
    :train_station => {
        :categories => ["public_transport"],
        :amenities => ["stop_station"]}
  }

  def self.inventory
    @@inventory
  end

  def self.count(group_name)
    counter = 0
    amenities = @@inventory[group_name.to_sym][:amenities]
    category  = @@inventory[group_name.to_sym][:categories]
    counter += OsmPoint.where(amenity: amenities).and(OsmPoint.where(category: category)).count
    counter += OsmLine.where(amenity: amenities).and(OsmLine.where(category: category)).count
    counter += OsmPolygone.where(amenity: amenities).and(OsmPolygone.where(category: category)).count
  end

  # Depending pilot's choice of amenities, we sum all the poi
  # amenities and categories to query on
  def self.trip_request_filter(trip_request)
    amenities   = []
    categories  = []
    if trip_request.proxy_food
      amenities   += @@inventory[:food][:amenities]
      categories  += @@inventory[:food][:categories]
    end
    if trip_request.proxy_fuel
      amenities   += @@inventory[:fuel_car][:amenities]
      categories  += @@inventory[:fuel_car][:categories]
    end
    if trip_request.proxy_bike_rental
      amenities   += @@inventory[:bike_rental][:amenities]
      categories  += @@inventory[:bike_rental][:categories]
    end
    if trip_request.proxy_car_rental
      amenities   += @@inventory[:car_rental][:amenities]
      categories  += @@inventory[:car_rental][:categories]
    end
    if trip_request.proxy_camp_site
      amenities   += @@inventory[:camp_site][:amenities]
      categories  += @@inventory[:camp_site][:categories]
    end
    if trip_request.proxy_hotel
      amenities   += @@inventory[:accomodation][:amenities]
      categories  += @@inventory[:accomodation][:categories]
    end
    filters = {:amenities => amenities, :categories => categories}
  end

  def self.count_groups_per_airport(airport)
    airport_group_inventory = {}
    counter = 0
    @@inventory.each_key do |group|
      counter += OsmPoint.where(airport_id: airport)
        .and(OsmPoint.where(amenity:  @@inventory[group][:amenities]))
        .and(OsmPoint.where(category: @@inventory[group][:categories]))
        .count
      counter += OsmLine.where(airport_id: airport)
        .and(OsmLine.where(amenity:  @@inventory[group][:amenities]))
        .and(OsmLine.where(category: @@inventory[group][:categories]))
        .count
      counter += OsmPolygone.where(airport_id: airport)
        .and(OsmPolygone.where(amenity:  @@inventory[group][:amenities]))
        .and(OsmPolygone.where(category: @@inventory[group][:categories]))
        .count

      airport_group_inventory[group] = counter 
    end
    airport_group_inventory.select { |key,value| value > 0 } #to retrieve not empty poi groups per airport
  end

end
