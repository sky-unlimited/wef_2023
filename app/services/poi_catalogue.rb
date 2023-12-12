class PoiCatalogue
  # If new groups added to trip_requests, please update PoiCatalogue.get_pois_group_per_trip_request
  @@inventory = {
    :food => {
        :categories => ["amenity"],
        :amenities => ["restaurant", "fast_food"],
        :icon => "food.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_food')},
    :beverage => {
        :categories => ["amenity"],
        :amenities => ["bar", "cafe"],
        :icon => "beverage.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_beverage')},
    :fuel_car => {
        :categories => ["amenity"],
        :amenities => ["fuel"],
        :icon => "fuel_car.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_fuel_car')},
    :fuel_plane => {
        :categories => ["aeroway"],
        :amenities => ["fuel"],
        :icon => "fuel_plane.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_fuel_plane')},
    :bike_rental => {
        :categories => ["amenity"],
        :amenities => ["bicycle_rental"],
        :icon => "bike_rental.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_bike_rental')},
    :car_rental => {
        :categories => ["amenity"],
        :amenities => ["car_rental"],
        :icon => "car_rental.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_car_rental')},
    :camp_site => {
        :categories => ["tourism"],
        :amenities => ["camp_site", "bivouac_site"],
        :icon => "camp_site.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_camp_site')},
    :accommodation => {
        :categories => ["tourism"],
        :amenities => ["hotel","chalet","guest_house","Gîte","hostel","motel"],
        :icon => "accommodation.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_accommodation')},
    :shop => {
        :categories => ["shop"],
        :amenities => ["bakery", "supermarket"],
        :icon => "shop.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_shop')},
    :bus_station => {
        :categories => ["highway", "amenity"],  #most are in highway
        :amenities => ["bus_station", "bus_stop"],
        :icon => "bus_station.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_bus_station')},
    :train_station => {
        :categories => ["railway"],
        :amenities => ["station", "stop_position"],
        :icon => "train_station.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_train_station')},
    :hiking_path => {
        :categories => ["hiking","route"],
        :amenities => ["hiking"],
        :icon => "hiking_path.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_hiking_path')},
    :biking_path => {
        :categories => ["bicycle"],
        :amenities => ["bicycle"],
        :icon => "biking_path.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_biking_path')},
    :power_cable => {
        :categories => ["power"],
        :amenities => ["cable","line","minor_cable","minor_line"],
        :icon => "power_cable.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_power_lines')},
    :coastline => {
        :categories => ["natural"],
        :amenities => ["coastline"],
        :icon => "coastline.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_coastline')},
    :aerodrome_polygone => {
        :categories => ["aeroway"],
        :amenities => ["airstrip","aerodrome"],
        :icon => "aerodrome.png",
        :label => I18n.t('activerecord.attributes.trip_request.airport')},
    :lake => {
        :categories => ["natural"],
        :amenities => ["water"],
        :icon => "lake.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_lake')},
    :spa => {
        :categories => ["amenity"],
        :amenities => ["spa"],
        :icon => "spa.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_spa')},
    :atm => {
        :categories => ["amenity"],
        :amenities => ["atm"],
        :icon => "atm.png",
        :label => I18n.t('activerecord.attributes.trip_request.proxy_atm')},
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
    selected_pois_group = get_pois_group_per_trip_request(trip_request)
    
    selected_pois_group.each do |group|
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(group.keys.first)

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

  def self.get_pois_group_per_trip_request(trip_request)
    # Create an array of pois
    pois_array = []

    # Iteration on trip_request pois
    pois_array << { :food           => @@inventory[:food] } if trip_request.proxy_food 
    pois_array << { :beverage       => @@inventory[:beverage] } if trip_request.proxy_beverage
    pois_array << { :fuel_car       => @@inventory[:fuel_car] } if trip_request.proxy_fuel_car
    #pois_array << { :fuel_plane     => @@inventory[:fuel_plane] } if trip_request.proxy_fuel_plane
    pois_array << { :bike_rental    => @@inventory[:bike_rental] } if trip_request.proxy_bike_rental
    pois_array << { :car_rental     => @@inventory[:car_rental] } if trip_request.proxy_car_rental
    pois_array << { :camp_site      => @@inventory[:camp_site] } if trip_request.proxy_camp_site
    pois_array << { :accommodation  => @@inventory[:accommodation] } if trip_request.proxy_accommodation
    pois_array << { :shop           => @@inventory[:shop] } if trip_request.proxy_shop
    pois_array << { :bus_station    => @@inventory[:bus_station] } if trip_request.proxy_bus_station
    pois_array << { :train_station  => @@inventory[:train_station] } if trip_request.proxy_train_station
    pois_array << { :hiking_path    => @@inventory[:hiking_path] } if trip_request.proxy_hiking_path
    pois_array << { :coastline      => @@inventory[:coastline] } if trip_request.proxy_coastline
    pois_array << { :lake           => @@inventory[:lake] } if trip_request.proxy_lake
    return pois_array
  end

  def self.get_group_from_amenity_and_category(amenity, category)
    main_group = nil
    self.inventory.each do |group, values|
      if values[:categories].include?(category) && values[:amenities].include?(amenity)
        main_group = group
        break
      end
    end
    return main_group
  end

  def self.get_relevant_poi_tags(osm_feature)
    relevant_tags = osm_feature.parsed_tags.select do |key,value|
      key.match("website") ||
      key.match("opening_hours") ||
      key.match("email") ||
      key.match("phone") ||
      key.match("cuisine") ||
      key.match("rooms") ||
      key.match("capacity") ||
      key.match("stars") ||
      key.match("description") ||
      key.match("self_service") ||
      key.match("outdoor_seating") ||
      key.match("facebook")
    end
    return relevant_tags
    #return osm_feature.parsed_tags #uncomment to display all tags
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
