class PoiCatalogue
  @@inventory = {
    :food => {
        :categories => ["amenity"],
        :amenities => ["restaurant", "fast_food"],
        :icon => "🍔",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_food')},
    :beverage => {
        :categories => ["amenity"],
        :amenities => ["bar", "cafe"],
        :icon => "🥤",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_beverage')},
    :fuel_car => {
        :categories => ["amenity"],
        :amenities => ["fuel"],
        :icon => "⛽",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_fuel_car')},
    :fuel_plane => {
        :categories => ["aeroway"],
        :amenities => ["fuel"],
        :icon => "✈️",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_fuel_plane')},
    :bike_rental => {
        :categories => ["amenity"],
        :amenities => ["bicycle_rental"],
        :icon => "🚲",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_bike_rental')},
    :car_rental => {
        :categories => ["amenity"],
        :amenities => ["car_rental"],
        :icon => "🚗",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_car_rental')},
    :camp_site => {
        :categories => ["tourism"],
        :amenities => ["camp_site", "bivouac_site"],
        :icon => "⛺",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_camp_site')},
    :accommodation => {
        :categories => ["tourism"],
        :amenities => ["hotel","chalet","guest_house","Gîte","hostel","motel"],
        :icon => "🏨",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_accommodation')},
    :shop => {
        :categories => ["shop"],
        :amenities => ["bakery", "supermarket"],
        :icon => "🛒",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_shop')},
    :bus_station => {
        :categories => ["highway", "amenity"],  #most are in highway
        :amenities => ["bus_station", "bus_stop"],
        :icon => "🚌",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_bus_station')},
    :train_station => {
        :categories => ["railway"],
        :amenities => ["station", "stop_position"],
        :icon => "🚆",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_train_station')},
    :hiking_path => {
        :categories => ["hiking","route"],
        :amenities => ["hiking"],
        :icon => "🥾",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_hiking_path')},
    :biking_path => {
        :categories => ["bicycle"],
        :amenities => ["bicycle"],
        :icon => "🚲",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_biking_path')},
    :power_cable => {
        :categories => ["power"],
        :amenities => ["cable","line","minor_cable","minor_line"],
        :icon => "⚡",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_power_lines')},
    :coastline => {
        :categories => ["natural"],
        :amenities => ["coastline"],
        :icon => "🏖️",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_coastline')},
    :aerodrome_polygone => {
        :categories => ["aeroway"],
        :amenities => ["airstrip","aerodrome"],
        :icon => "✈️",
        :label => I18n.t('activerecord.attributes.trip_request.airport')},
    :lake => {
        :categories => ["natural"],
        :amenities => ["water"],
        :icon => "🛟",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_lake')},
  }

  def self.inventory
    @@inventory
  end

  def self.count(group_name)
    counter = 0
    amenities = @@inventory[group_name][:amenities]
    category  = @@inventory[group_name][:categories]
    counter += OsmPoint.where(amenity: amenities).and(OsmPoint.where(category: category)).count
    counter += OsmLine.where(amenity: amenities).and(OsmLine.where(category: category)).count
    counter += OsmPolygone.where(amenity: amenities).and(OsmPolygone.where(category: category)).count
  end

  # Depending pilot's choice of amenities, we list all airports
  # matching ALL criterias (intersection)
  def self.airports_matching_pois(trip_request)
    airports_ids = []

    if trip_request.proxy_food
      # Get airports having poi group
      airports_ids += get_airports_ids(:food)
    end
    if trip_request.proxy_beverage
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:beverage)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_fuel_car
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:fuel_car)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_fuel_plane
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:fuel_plane)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_bike_rental
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:bike_rental)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_car_rental
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:car_rental)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_camp_site
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:camp_site)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_accommodation
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:accommodation)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_shop
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:shop)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_bus_station
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:bus_station)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_train_station
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:train_station)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_hiking_path
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:hiking_path)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_coastline
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:coastline)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end
    if trip_request.proxy_lake
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(:lake)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids = airports_ids & temp_airports_ids
      end
    end

    return Airport.where(id: airports_ids)
  end

  def self.count_groups_per_airport(airport)
    airport_group_inventory = {}
    @@inventory.each_key do |group|
      next if group == :aerodrome_polygone
      counter = 0
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

  def self.poi_per_group_and_airport(airport)
    list_pois = {}
    @@inventory.each_key do |group|
      osm_points = OsmPoint.where(airport_id: airport)
        .and(OsmPoint.where(amenity:      @@inventory[group][:amenities]))
        .and(OsmPoint.where(category:     @@inventory[group][:categories]))
      osm_lines = OsmLine.where(airport_id: airport)
        .and(OsmLine.where(amenity:       @@inventory[group][:amenities]))
        .and(OsmLine.where(category:      @@inventory[group][:categories]))
      osm_polygones = OsmPolygone.where(airport_id: airport)
        .and(OsmPolygone.where(amenity:   @@inventory[group][:amenities]))
        .and(OsmPolygone.where(category:  @@inventory[group][:categories]))
      
      # Variables
      points_array = []
      lines_array = []
      polygones_array = []
    
      # We iterate on each record to store what we need
      osm_points.each do |point|
        points_hash = {     :name       => point.osm_name,
                            :tags       => point.parsed_tags,
                            :geojson    => RGeo::GeoJSON.encode(point.way).to_json,
                            :distance   => point.distance.to_i}
        points_array.push(points_hash)
      end
      osm_lines.each do |line|
        lines_hash = {      :name       => line.osm_name,
                            :tags       => line.parsed_tags,
                            :geojson    => RGeo::GeoJSON.encode(line.way).to_json,
                            :distance   => line.distance.to_i}
        lines_array.push(lines_hash)
      end
      osm_polygones.each do |polygone|
        polygones_hash = {  :name       => polygone.osm_name,
                            :tags       => polygone.parsed_tags,
                            :geojson    => RGeo::GeoJSON.encode(polygone.way).to_json,
                            :distance   => polygone.distance.to_i}
        polygones_array.push(polygones_hash)
      end
    pois_array = []
    pois_array = (points_array + lines_array + polygones_array)
    
    # We sort the poi's by distance
    sorted_pois_array = pois_array.sort_by { |poi| poi[:distance] }

    # We assign all pois per current group iteration
    list_pois[group]  = sorted_pois_array
    end
    return list_pois
  end

  private

  def self.get_airports_ids(poi_group)
    osm_points_airports     =  OsmPoint.where(amenity: @@inventory[poi_group][:amenities])
                               .and(OsmPoint.where(category: @@inventory[poi_group][:categories]))
                               .pluck(:airport_id)
    osm_lines_airports      =  OsmLine.where(amenity: @@inventory[poi_group][:amenities])
                                .and(OsmLine.where(category: @@inventory[poi_group][:categories]))
                                .pluck(:airport_id)
    osm_polygones_airports  =  OsmPolygone.where(amenity: @@inventory[poi_group][:amenities])
                                .and(OsmPolygone.where(category: @@inventory[poi_group][:categories]))
                                .pluck(:airport_id)

    # Combine the results from all three tables
    osm_airport_ids = (osm_points_airports + osm_lines_airports + osm_polygones_airports).uniq
  end

end
