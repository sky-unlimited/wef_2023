import L from "leaflet";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    departureAirport: Object,
    airportsDestinationMap: Array,
  };

  static targets = ["map"];

  connect() {
    console.log("Openstreetmap connected!");
    this.display();
  }

  display() {
    // Store the reference to the controller instance
    const controller = this;

    /*
      ------------------------------------------------------
      We setup the layers
      ------------------------------------------------------
    */
    // Tile Layer - Default - Light
    var Esri_WorldGrayCanvas = L.tileLayer(
      "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
      {
        attribution: "Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ",
        maxZoom: 16,
      }
    );

    // Tile Layer - Standard OpenStreetMap
    var OpenStreetMap_Mapnik = L.tileLayer(
      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      {
        maxZoom: 19,
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      }
    );

    // Tile Layer - Openweathermap Winds
    var OpenWeatherMap_Wind = L.tileLayer(
      "http://{s}.tile.openweathermap.org/map/wind/{z}/{x}/{y}.png?appid={apiKey}",
      {
        maxZoom: 19,
        attribution:
          'Map data &copy; <a href="http://openweathermap.org">OpenWeatherMap</a>',
        apikey: "<your apikey>",
        opacity: 0.5,
      }
    );

    // Tile Layer - CycloOSM
    var CyclOSM = L.tileLayer(
      "https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png",
      {
        maxZoom: 20,
        attribution:
          '<a href="https://github.com/cyclosm/cyclosm-cartocss-style/releases" title="CyclOSM - Open Bicycle render">CyclOSM</a> | Map data: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      }
    );

    // Tile Layer - Hiking
    var MtbMap = L.tileLayer(
      "http://tile.mtbmap.cz/mtbmap_tiles/{z}/{x}/{y}.png",
      {
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &amp; USGS',
      }
    );

    // We create the base layers and add default one to the map
    this.map = L.map(this.mapTarget, {
      center: [
        this.departureAirportValue.geojson.coordinates[1],
        this.departureAirportValue.geojson.coordinates[0],
      ],
      zoom: 6,
      layers: [Esri_WorldGrayCanvas],
    });

    /*
      ------------------------------------------------------
      We display the flight tracks of destinations
      ------------------------------------------------------
    */

    /*
      ------------------------------------------------------
      We display the airport homebase marker
      ------------------------------------------------------
    */
    var markersTable = []; // Used to zoom map on those destination markers
    const airport_departure = this.departureAirportValue;
    var iconDeparture = L.icon({
      iconUrl: airport_departure.icon_url,
      iconSize: [20, 20], // size of the icon
      iconAnchor: [10, 10], // point of the icon which will correspond to marker's location
      popupAnchor: [0, -20], // point from which the popup should open relative to the iconAnchor
    });

    var marker = L.marker(
      [
        airport_departure.geojson.coordinates[1],
        airport_departure.geojson.coordinates[0],
      ],
      { icon: iconDeparture }
    ).addTo(this.map);

    // set the opacity of the marker
    marker.setOpacity(1);

    // Pop up information
    marker.bindPopup(
      "<b>" + airport_departure.icao + "</b></br>" + airport_departure.name
    );

    // We add homebase marker to boundaries
    markersTable.push(marker);

    /*
      ------------------------------------------------------
      We display the airports inside the flyzone
      ------------------------------------------------------
    */

    /*
      ------------------------------------------------------
      We display the airports respecting pilot's criterias
      ------------------------------------------------------
    */

    /*
      ------------------------------------------------------
      We display the top destinations airports
      ------------------------------------------------------
    */
    var airportsDestinationGroup = L.layerGroup();

    this.airportsDestinationMapValue.forEach((airport) => {
      //TODO: We should not reload the airport if already present in airportsFlyzoneGroup
      // We create a marker for each airport
      var iconDestination = L.icon({
        iconUrl: airport.icon_url,
        iconSize: [20, 20], // size of the icon
        iconAnchor: [10, 10], // point of the icon which will correspond to marker's location
        popupAnchor: [0, -20], // point from which the popup should open relative to the iconAnchor
      });

      var marker = L.marker(
        [airport.geojson.coordinates[1], airport.geojson.coordinates[0]],
        { icon: iconDestination }
      );

      // set the opacity of the marker
      marker.setOpacity(1);

      // We add a popup to each marker
      marker.bindPopup(
        "<b>" +
          airport.icao +
          "</b></br>" +
          airport.name +
          "</br>" +
          "<a href=" +
          airport.detail_link +
          " target='_blank'>Details</a>"
      );

      // Creating a Layer Group of matching criterias airports
      airportsDestinationGroup.addLayer(marker);
      markersTable.push(marker);
    });
    /*
      ------------------------------------------------------
      We display the flyzone departure
      ------------------------------------------------------
    */

    /*
      ------------------------------------------------------
      We display the flyzone return
      ------------------------------------------------------
    */

    /*
      ------------------------------------------------------
      We display the common flyzone -> destination flyzone
      ------------------------------------------------------
    */

    /*
      ------------------------------------------------------
      We display the distance/time circles 1 hour step
      ------------------------------------------------------
    */

    /*
      ------------------------------------------------------
      LayerGroup, scale, controlsl layers, ...
      ------------------------------------------------------
    */
    // Adding the LayerGroup to the map
    airportsDestinationGroup.addTo(this.map);

    // Display a scale on the map
    L.control.scale({ imperial: false }).addTo(this.map);

    // Display the control layers
    var baseLayers = {
      LightMap: Esri_WorldGrayCanvas,
      OpenStreetMap: OpenStreetMap_Mapnik,
      "Cyclo OSM": CyclOSM,
      "Hiking/Rando": MtbMap,
    };

    var layerControl = L.control.layers(baseLayers).addTo(this.map);

    // We create a group representating the featureBounds object
    var boundaryGroup = new L.featureGroup(markersTable);

    // We adapt the zoom on the group
    this.map.fitBounds(boundaryGroup.getBounds().pad(0.5));
  }

  disconnect() {
    this.map.remove();
  }
}
