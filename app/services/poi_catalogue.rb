# This module provides all amenities that are used and related functions
module PoiCatalogue
  module_function

  def inventory
    POI_CATALOGUE
  end

  def count(group_name)
    amenities = inventory[group_name]['amenities']
    category  = inventory[group_name]['categories']
    OsmPoi.where(amenity: amenities).and(OsmPoi.where(category:)).count
  end

  # Depending pilot's choice of amenities, we list all airports ids
  # matching ALL criterias (intersection)
  def airports_matching_pois(trip_request)
    airports_ids = []
    selected_pois_group = get_pois_group_per_trip_request(trip_request)

    selected_pois_group.each do |group|
      # Get airports having poi group
      temp_airports_ids = get_airports_ids(group.keys.first)

      # We make an intersection to match all criterias
      if airports_ids.empty?
        airports_ids += temp_airports_ids
      else
        airports_ids &= temp_airports_ids
      end
    end
    airports_ids
  end

  def count_groups_per_airport(airport)
    airport_group_inventory = {}
    inventory.each_key do |group|
      next if group == :aerodrome_polygone

      counter = OsmPoi.where(airport_id: airport)
                      .and(OsmPoi.where(amenity:
                                        inventory[group]['amenities']))
                      .and(OsmPoi.where(category:
                                        inventory[group]['categories']))
                      .count

      airport_group_inventory[group] = counter
    end
    # to retrieve not empty poi groups per airport
    airport_group_inventory.select do |_key, value|
      value.positive?
    end
  end

  def poi_per_group_and_airport(airport)
    list_pois = {}
    inventory.each_key do |group|
      osm_pois = OsmPoi.where(airport_id: airport)
                       .and(OsmPoi.where(amenity:
                                         inventory[group]['amenities']))
                       .and(OsmPoi.where(category:
                                         inventory[group]['categories']))

      # Variables
      pois_array = []

      # We iterate on each record to store what we need
      osm_pois.each do |poi|
        pois_hash = { name: poi.osm_name,
                      tags: poi.parsed_tags,
                      geojson: RGeo::GeoJSON.encode(poi.geom_point).to_json,
                      distance: poi.distance.to_i }
        pois_array.push(pois_hash)
      end

      # We sort the poi's by distance
      sorted_pois_array = pois_array.sort_by { |poi| poi[:distance] }

      # We assign all pois per current group iteration
      list_pois[group] = sorted_pois_array
    end
    list_pois
  end

  def get_pois_group_per_trip_request(trip_request)
    # Create an array of pois
    pois_array = []

    # Iteration on trip_request pois
    pois_array << { food: inventory['food'] } if trip_request.proxy_food
    if trip_request.proxy_beverage
      pois_array << { beverage: inventory['beverage'] }
    end
    if trip_request.proxy_fuel_car
      pois_array << { fuel_car: inventory['fuel_car'] }
    end
    if trip_request.proxy_bike_rental
      pois_array << { bike_rental: inventory['bike_rental'] }
    end
    if trip_request.proxy_car_rental
      pois_array << { car_rental: inventory['car_rental'] }
    end
    if trip_request.proxy_camp_site
      pois_array << { camp_site: inventory['camp_site'] }
    end
    if trip_request.proxy_accommodation
      pois_array << { accommodation: inventory['accommodation'] }
    end
    pois_array << { shop: inventory['shop'] } if trip_request.proxy_shop
    if trip_request.proxy_bus_station
      pois_array << { bus_station: inventory['bus_station'] }
    end
    if trip_request.proxy_train_station
      pois_array << { train_station: inventory['train_station'] }
    end
    if trip_request.proxy_hiking_path
      pois_array << { hiking_path: inventory['hiking_path'] }
    end
    if trip_request.proxy_coastline
      pois_array << { coastline: inventory['coastline'] }
    end
    pois_array << { lake: inventory['lake'] } if trip_request.proxy_lake
    pois_array
  end

  def get_group_from_amenity_and_category(amenity, category)
    main_group = nil
    inventory.each do |group, values|
      next unless values['categories'].include?(category) &&
                  values['amenities'].include?(amenity)

      main_group = group
      next
    end
    main_group
  end

  def get_relevant_poi_tags(osm_feature)
    osm_feature.parsed_tags.select do |key, _value|
      key.match('website') ||
        key.match('opening_hours') ||
        key.match('email') ||
        key.match('phone') ||
        key.match('cuisine') ||
        key.match('rooms') ||
        key.match('capacity') ||
        key.match('stars') ||
        key.match('description') ||
        key.match('self_service') ||
        key.match('outdoor_seating') ||
        key.match('facebook')
    end

    # return osm_feature.parsed_tags #uncomment to display all tags
  end

  def get_airports_ids(poi_group)
    OsmPoi.where(amenity: PoiCatalogue.inventory[poi_group.to_s]['amenities'])
          .and(OsmPoi.where(category: PoiCatalogue
                                      .inventory[poi_group.to_s]['categories']))
          .pluck(:airport_id)
  end
end
