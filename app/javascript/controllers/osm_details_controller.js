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
      layers: [OpenStreetMap_Mapnik]
    });
    /*
      ------------------------------------------------------ 
      We display the osm points
      ------------------------------------------------------ 
    */
    this.pointsValue.forEach((point) => {
      // Create icon
      var iconL = L.icon({
      iconUrl:      point.icon_url,
      iconSize:     [32, 32], // size of the icon
      iconAnchor:   [16, 16],   // point of the icon which will correspond to marker's location
      popupAnchor:  [0, -32] // point from which the popup should open relative to the iconAnchor
      });

      // Create a marker for each osm point
      var marker = L.marker([point.latitude, point.longitude], {icon: iconL}).addTo(this.map);

      // Create tags list for popup
      var tag_items = "";
      Object.entries(point.tags).forEach(([key, value]) => {
        if (key.includes("website") || key.includes("facebook")) {
          tag_items += `<b>${key}</b>: <a href="${value}" target="_blank">web</a></br>`;
        } else {
          tag_items += `<b>${key}</b>: ${value}</br>`;
        }
      });

      // Create popup
      if (point.name != null && tag_items.length !== 0) {
        var osm_link = `</br><a href="https://www.openstreetmap.org" 
                        target="_blank">https://www.openstreetmap.org/</a>
                        </br><b>osm_id:</b> ${point.osm_id }`
        if (point.name == null) {
          marker.bindPopup(`${tag_items}${osm_link}`)
        } else {
          marker.bindPopup(`<h2>${point.name}</h2>${tag_items}${osm_link}`)
        }
      }
    });

    /*
      ------------------------------------------------------ 
      LayerGroup, scale, controlsl layers, ...
      ------------------------------------------------------ 
    */
    // Display a scale on the map
    L.control.scale({ imperial: false }).addTo(this.map);
    
    // Display the control layers
    var baseLayers = {
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
