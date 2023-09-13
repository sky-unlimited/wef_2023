import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapse"
export default class extends Controller {
  static targets = [ 'content' ];

  connect() {
    console.log("collapse connected!");
  }
  toggle(event) {
    this.contentTarget.classList.toggle("show");
  }

}
