import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="airport-searcher"
export default class extends Controller {
  static targets = [ "searchbox", "result" ];

  connect() {
    console.log("Airport searcher connected!");
    this.baseUrl = this.data.get('base-urlValue');
  }

  display = (array) => {
    this.resultTarget.innerHTML = "";
    array.forEach((airport) => {
      const line = `<li><a class="link-dark link-no-underline" id="${airport.id}" href="${this.baseUrl}/trip_requests/new?airport=${airport.id}">${airport.name} (${airport.icao})</a></li>`;
      this.resultTarget.insertAdjacentHTML("afterbegin", line);
    });
  };

  eventKey(e) {
    const url = `${this.baseUrl}/api/v1/airports/find?query=`;
    fetch(`${url}${this.searchboxTarget.value}`)
      .then(response => response.json())
      .then(data => this.display(data));
  };
}
