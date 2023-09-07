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
    :accomodations => {
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

end
