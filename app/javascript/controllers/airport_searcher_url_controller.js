import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="airport-searcher"
export default class extends Controller {
  static targets = [ "searchbox", "resultList", "resultItem" ];

  connect() {
    console.log("Airport searcher url connected!");
    this.baseUrl  = this.data.get('base-urlValue');
    this.locale   = this.data.get('localeValue');
  }

  display = (array) => {
    this.clearResults();
    // We load the locale
    var locale = "";
    if(this.locale != 'en') {
      locale = `${this.locale}/`;
    }
    array.forEach((airport) => {
      const line =  `<li><a href="${this.baseUrl}/${locale}airports/${airport.id}" 
                    class="link-dark link-no-underline" 
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
      .then(response => response.json())
      .then(data => this.display(data));
  };
  
  copyResult(event) {
    event.preventDefault(); // Prevent the default click behavior
    const resultItem = event.target;
    const selectedText = resultItem.textContent.trim();
    this.searchboxTarget.value = selectedText;
    this.airportIdTarget.value = resultItem.id
    this.clearResults();
  }

  clearResults() {
    this.resultListTarget.innerHTML = "";
  }

}
