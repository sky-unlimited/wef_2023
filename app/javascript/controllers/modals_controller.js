import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modals"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
    console.log("modal connected!");
  }

  display() {
    console.log(this.modalTarget);
    this.modalTarget.style.display = "block";
  }

  close(event) {
    event.preventDefault();
    this.modalTarget.style.display = "none";
  }
}
