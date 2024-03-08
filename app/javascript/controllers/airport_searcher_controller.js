import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="airport-searcher"
export default class extends Controller {
  static targets = ["searchbox", "resultList", "resultItem", "airportId"];

  connect() {
    console.log("Airport searcher connected!");
    this.baseUrl = this.data.get("base-urlValue");
  }

  display = (array) => {
    this.clearResults();
    this.resultListTarget.classList.add("card");
    array.forEach((airport) => {
      const line = `<li class="list-unstyled"><a href="#"
                    class="text-decoration-none text-dark"
                    data-action="click->airport-searcher#copyResult" data-airport-searcher-target="resultItem"
                    id="${airport.id}">
                    ${airport.name} (${airport.icao})
                    </a></li>`;
      this.resultListTarget.insertAdjacentHTML("afterbegin", line);
    });
  };

  eventKey(e) {
    const url = `${this.baseUrl}/api/v1/airports/find?query=`;
    fetch(`${url}${this.searchboxTarget.value}`)
      .then((response) => response.json())
      .then((data) => this.display(data));
  }

  copyResult(event) {
    event.preventDefault(); // Prevent the default click behavior
    const resultItem = event.target;
    const selectedText = resultItem.textContent.trim();
    this.searchboxTarget.value = selectedText;
    this.airportIdTarget.value = resultItem.id;
    this.clearResults();
  }

  clearResults() {
    this.resultListTarget.innerHTML = "";
  }

  clearSearcher() {
    this.searchboxTarget.value = "";
    this.airportIdTarget.value = "";
    this.searchboxTarget.focus();
  }
}
