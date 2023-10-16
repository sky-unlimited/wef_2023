import L from 'leaflet';
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="osm-details"
export default class extends Controller {
  static values = {
    airport: Object,
    points: Array
  }

  static targets = [ 'map' ]

  connect() {
    console.log("Openstreetmap airport details connected!");
    this.displayMap();
    console.log(this.airportValue);
    console.log(this.pointsValue);
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
	    apikey: '<your apikey>',
	    opacity: 0.5
    });

    // Tile Layer - CycloOSM
    var CyclOSM = L.tileLayer('https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png', {
	    maxZoom: 20,
	    attribution: '<a href="https://github.com/cyclosm/cyclosm-cartocss-style/releases" title="CyclOSM - Open Bicycle render">CyclOSM</a> | Map data: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    });

    // Tile Layer - Hiking
    var MtbMap = L.tileLayer('http://tile.mtbmap.cz/mtbmap_tiles/{z}/{x}/{y}.png', {
	    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &amp; USGS'
    });

    // We create the base layers and add default one to the map
    this.map = L.map(this.mapTarget, {
      center: [ this.airportValue.latitude, this.airportValue.longitude ],
      zoom: 13,
      layers: [Esri_WorldGrayCanvas]
    });
    /*
      ------------------------------------------------------ 
      We display the osm points
      ------------------------------------------------------ 
    */
    this.pointsValue.forEach((point) => {
      // We create a marker for each osm point
      console.log(point);
      console.log(typeof(point));
      console.log(point.geojson);
      L.geoJSON(point.geojson).addTo(this.map)
    });
    console.log(this.map);

    /*
      ------------------------------------------------------ 
      LayerGroup, scale, controlsl layers, ...
      ------------------------------------------------------ 
    */
    // Display a scale on the map
    L.control.scale({ imperial: false }).addTo(this.map);
    
    // Display the control layers
    var baseLayers = {
      "LightMap": Esri_WorldGrayCanvas,
      "OpenStreetMap": OpenStreetMap_Mapnik,
      "Cyclo OSM": CyclOSM,
      "Hiking/Rando": MtbMap
    };
    var layerControl = L.control.layers(baseLayers).addTo(this.map);
  }

  disconnect(){
    this.map.remove()
  }
}
