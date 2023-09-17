/*
 * Basemaps: https://leaflet-extras.github.io/leaflet-providers/preview/
 * Mention how to fix a map: https://www.openstreetmap.org/fixthemap
 * Production: accept https://operations.osmfoundation.org/policies/tiles/
 * 
 */

import L from 'leaflet';
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    departureAirport: Object,
    airportsMatchingCriteriasMap: Array,
    airportsFlyzoneMap: Array,
    flyzoneCommonPolygon: Object,
    flyzoneOutbound: Object,
    flyzoneInbound: Object,
    flightTracks: Array
  }

  static targets = [ 'map' ]

  connect() {
    console.log("Openstreetmap connected!");
    this.displayMap();
  }

  displayMap() {
    // Store the reference to the controller instance
    const controller = this;

    /*
      ------------------------------------------------------ 
      We setup the layers
      ------------------------------------------------------ 
    */
    // Tile Layer - Default - Light
    var Esri_WorldGrayCanvas = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}', {
	  attribution: 'Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ',
	  maxZoom: 16
    });

    // Tile Layer - Standard OpenStreetMap
    var OpenStreetMap_Mapnik = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
	  maxZoom: 19,
	  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    });

    // Tile Layer - Openweathermap Winds
    var OpenWeatherMap_Wind = L.tileLayer('http://{s}.tile.openweathermap.org/map/wind/{z}/{x}/{y}.png?appid={apiKey}',
    {
  	  maxZoom: 19,
	    attribution: 'Map data &copy; <a href="http://openweathermap.org">OpenWeatherMap</a>',
	    apiKey: '<insert your api key here>',
	    opacity: 0.5
    });

    // We create the base layers and add default one to the map
    this.map = L.map(this.mapTarget, {
      center: [ this.departureAirportValue.geojson.coordinates[1],
                this.departureAirportValue.geojson.coordinates[0]],
      zoom: 6,
      layers: [Esri_WorldGrayCanvas]
    });

    /*
      ------------------------------------------------------ 
      We display the flight tracks of destinations
      ------------------------------------------------------ 
    */
    this.flightTracksValue.forEach((track) => {
      if (track.is_in_flyzone == true) {
        var myStyle = {
        opacity: 0.7,
        weight: 3,
        color: "#FF00FF"
        }
      }
      else
      {
        var myStyle = {
        opacity: 0.7,
        weight: 3,
        color: "#FF00FF", // green: "#dc3545"
        dashArray: "5,10",
        }
      };
    L.geoJSON(track.line_geojson, { style: myStyle }).addTo(this.map)});

    /*
      ------------------------------------------------------ 
      We display the airport homebase marker
      ------------------------------------------------------ 
    */
    const airport = this.departureAirportValue
    var iconDeparture = L.icon({
    iconUrl: airport.icon_url,
    iconSize:     [20, 20], // size of the icon
    iconAnchor:   [10, 10],   // point of the icon which will correspond to marker's location
    popupAnchor:  [0, -20] // point from which the popup should open relative to the iconAnchor
    });

    var marker = L.marker([airport.geojson.coordinates[1], airport.geojson.coordinates[0]], {icon: iconDeparture}).addTo(this.map);

    // set the opacity of the marker
    marker.setOpacity(1);

    // Pop up information
    marker.bindPopup("<b>" + airport.icao + "</b></br>" + airport.name);

    
    /*
      ------------------------------------------------------ 
      We display the airports inside the flyzone
      ------------------------------------------------------ 
    */
    var airportsFlyzoneGroup = L.layerGroup();

    this.airportsFlyzoneMapValue.forEach((airport) => {
      // We define the size of icon // airport size
      var size = 14
      var size_text = ""
      switch(airport.airport_type) {
        case 'small_airport':
          size = 10;
          size_text = "small"
          break;
        case 'medium_airport':
          size = 12;
          size_text = "medium"
          break;
        case 'large_airport':
          size = 14;
          size_text = "large"
          break;
      }

      // We create a marker for each airport
      var iconDestination = L.icon({
      iconUrl: airport.icon_url,
      iconSize:     [size, size], // size of the icon
      iconAnchor:   [size/2, size/2],   // point of the icon which will correspond to marker's location
      popupAnchor:  [0, -size] // point from which the popup should open relative to the iconAnchor
      });

      var marker = L.marker([airport.geojson.coordinates[1], airport.geojson.coordinates[0]], {icon: iconDestination});

      // set the opacity of the marker
      marker.setOpacity(1);

      // We add a popup to each marker
      marker.bindPopup("<b>" + airport.icao + "</b></br>" + airport.name + "</br><em>" + size_text + "</em>");

      // Creating a Layer Group of matching criterias airports
      airportsFlyzoneGroup.addLayer(marker);
    });

    /*
      ------------------------------------------------------ 
      We display the airports respecting pilot's criterias
      ------------------------------------------------------ 
    */
    var airportsMatchingCriteriasGroup = L.layerGroup();

    this.airportsMatchingCriteriasMapValue.forEach((airport) => {
      // We define the size of icon // airport size
      var size = 14
      var size_text = ""
      switch(airport.airport_type) {
        case 'small_airport':
          size = 10;
          size_text = "small"
          break;
        case 'medium_airport':
          size = 12;
          size_text = "medium"
          break;
        case 'large_airport':
          size = 14;
          size_text = "large"
          break;
      }
      //TODO: We should not reload the airport if already present in airportsFlyzoneGroup
      // We create a marker for each airport
      var iconDestination = L.icon({
      iconUrl: airport.icon_url,
      iconSize:     [14, 14], // size of the icon
      iconAnchor:   [7, 7],   // point of the icon which will correspond to marker's location
      popupAnchor:  [0, -14] // point from which the popup should open relative to the iconAnchor
      });

      var marker = L.marker([airport.geojson.coordinates[1], airport.geojson.coordinates[0]], {icon: iconDestination});

      // set the opacity of the marker
      marker.setOpacity(0.2);

      // We add the marker to a table in order used to fit the view on the markers
      //markersTable.push(marker);

      // We add a popup to each marker
      //marker.bindPopup(airport.info_window).openPopup();
      marker.bindPopup("<b>" + airport.icao + "</b></br>" + airport.name + "</br><em>" + size_text + "</em>");

      // Creating a Layer Group of matching criterias airports
      airportsMatchingCriteriasGroup.addLayer(marker);
    });

    /*
      ------------------------------------------------------ 
      We display the flyzone departure
      ------------------------------------------------------ 
    */
    // We display the flyzone departure
    var myStyle = {
      opacity: 0.3,
      fillColor: "green",
      weight: 0,
    };
    var flyZoneOutbound = L.geoJSON(this.flyzoneOutboundValue, { style: myStyle }).addTo(this.map)

    /*
      ------------------------------------------------------ 
      We display the flyzone return
      ------------------------------------------------------ 
    */
    var myStyle = {
      opacity: 0.3,
      fillColor: "green",
      weight: 0,
    };
    var flyZoneInbound = L.geoJSON(this.flyzoneInboundValue, { style: myStyle }).addTo(this.map)

    /*
      ------------------------------------------------------ 
      We display the common flyzone -> destination flyzone
      ------------------------------------------------------ 
    */
    var myStyle = {
      opacity: 0.3,
      fillColor: "green",
      weight: 0,
    };
    var flyzoneCommonPolygon = L.geoJSON(this.flyzoneCommonPolygonValue, { style: myStyle }).addTo(this.map)

    /*
      ------------------------------------------------------ 
      LayerGroup, scale, controlsl layers, ...
      ------------------------------------------------------ 
    */
    // Adding the LayerGroup to the map
    airportsMatchingCriteriasGroup.addTo(this.map);
    airportsFlyzoneGroup.addTo(this.map);

    // Display a scale on the map
    L.control.scale({ imperial: false }).addTo(this.map);

    // Display the control layers
    var baseLayers = {
      "LightMap": Esri_WorldGrayCanvas,
      "OpenStreetMap": OpenStreetMap_Mapnik
    };
    var Overlays = {
      "Fly Zone - Cumulative": flyzoneCommonPolygon,
      "Fly Zone - outbound": flyZoneOutbound,
      "Fly Zone - inbound": flyZoneInbound,
      "Airports matching criterias": airportsMatchingCriteriasGroup,
      "Airports in flyzone": airportsFlyzoneGroup
    };
    L.control.layers(baseLayers, Overlays).addTo(this.map);

  }
  disconnect(){
    this.map.remove()
  }
}
