import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="airport-searcher"
export default class extends Controller {
  static targets = [ "searchbox", "result" ];

  connect() {
    console.log("Airport searcher connected!");
  }

  display = (array) => {
    console.log(array);
    this.resultTarget.innerHTML = "";
    array.forEach((airport) => {
      const line = `<li id="${airport.id}">${airport.name} (${airport.icao})</li>`;
      this.resultTarget.insertAdjacentHTML("afterbegin", line);
    });
  };

  eventKey(e) {
    //TODO: Retrieve the api url from correct environment
    const url = "http://localhost:3000/api/v1/airports/find?query=";
    console.log(`${url}${this.searchboxTarget.value}`);
    fetch(`${url}${this.searchboxTarget.value}`)
      .then(response => response.json())
      .then(data => this.display(data));
  };
}
