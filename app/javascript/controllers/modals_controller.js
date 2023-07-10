import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modals"
export default class extends Controller {
  connect() {
    console.log("modal connected!");
  }

  close(event) {
    event.preventDefault();

    // Remove from parent
    const modal = docuement.getElementById("modal");
    modal.innerHTML = "";

    // Remove the src attributefrom the modal
    modal.removeAttribute("src");

    // Remove complete attribute
    modal.removeAttribute("complete");
  }
}
