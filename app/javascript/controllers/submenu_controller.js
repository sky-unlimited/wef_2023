import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["account", "flag"];

  connect() {
    console.log("Submenu connected!");
  }

  displayMenuAccount() {
    this.accountTarget.classList.toggle("show");
  }
  displayMenuFlag() {
    this.flagTarget.classList.toggle("show");
  }
}
