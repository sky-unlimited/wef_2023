import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="loading"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
    console.log("Loading controller connected");
    console.log(this.modalTarget);
  }

  loader() {
    this.modalTarget.style.display = "block";
  }
}
