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
    tile: Object,
    airports: Array
  }

  static targets = [ 'map' ]

  connect() {
    console.log("Openstreetmap connected!")
    this.displayMap();
  }

  displayMap() {
    // Store the reference to the controller instance
    const controller = this;

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
      center: [49.6, 6.2],
      zoom: 6,
      layers: [Esri_WorldGrayCanvas]
    });

    // We add the airport polygon for ELLX
    //var airportELLX = L.geoJSON(this.airportPolygonValue).addTo(this.map);

    // We add the weather tile
    //var weatherLayer = L.geoJSON(this.tileValue).addTo(this.map);
    
    // Hereunder an example to manage the layer on/off depending on zoom
    /* 
    var weatherLayer = L.geoJSON(this.tileValue , {
      onEachFeature: function(feature, layer) {
        layer.options.visible = false;

        // Add an event listener to update visibility on zoomend
        controller.map.on('zoomend', function() {

          // Define the threshold zoom level
          var threshold = 8; // Set your desired threshold level

          // Get the current zoom level
          var zoomLevel = controller.map.getZoom();
          console.log("zoom:" + zoomLevel);

          // Update the visibility of the layer based on the zoom level
          if (zoomLevel >= threshold) {
            if (!controller.map.hasLayer(layer)) {
              controller.map.addLayer(layer); // Add the layer to the map
              }
            } else {
            if (controller.map.hasLayer(layer)) {
              controller.map.removeLayer(layer); // Remove the layer from the map
              }
            }
        });
      }
    })
    */
    //this.map.fitBounds(weatherLayer.getBounds());
    //this.map.fitBounds(airportELLX.getBounds());

    // We display the airport homebase marker
    var myStyle = {
      opacity: 0.1,
      alt: "ELLX",
      title: "ELLX"
    };
    //L.geoJSON(this.airportValue, { style: myStyle }).addTo(this.map)

    // We display all airports
    var airportsGroup = L.layerGroup();

    this.airportsValue.forEach((airport) => {
      var airport_color = "";
      var airport_radius = 0;
      var airport_weight = 0;
      switch(airport.airport_type) {
        case "small_airport":
          airport_color = "green"
          airport_radius = 100
          airport_weight = 1
          break;
        case "medium_airport":
          airport_color = "blue"
          airport_radius = 300
          airport_weight = 2
          break;
        default:
          airport_color = "#FF00FF"
          airport_radius = 500
          airport_weight = 3
          break;
      }
      var circle = L.circle([airport.geojson.coordinates[1], airport.geojson.coordinates[0]], {
        color: airport_color,
        weight: airport_weight,
        fillColor: airport_color,
        fillOpacity: 0.2,
        radius: airport_radius
      });
      

      // Binding a popup with airport names
      circle.bindPopup("<b>" + airport.icao + "</b></br>" + airport.name);

      // Creating a Layer Group of airports
      airportsGroup.addLayer(circle);
    });
    // Adding the LayerGroup to the map
    airportsGroup.addTo(this.map);

    // Display a scale on the map
    L.control.scale({ imperial: false }).addTo(this.map);

    // Display the control layers
    var baselayers = {
      "LightMap": Esri_WorldGrayCanvas,
      "OpenStreetMap": OpenStreetMap_Mapnik
    };
    var overlays = {
      //"Weather Layer": weatherLayer,
      //"Airports": airportsGroup,
      //"ELLX": airportELLX
    };
    //L.control.layers(baselayers, overlays).addTo(this.map);
    L.control.layers(baselayers).addTo(this.map);

  }
  disconnect(){
    this.map.remove()
  }
}
