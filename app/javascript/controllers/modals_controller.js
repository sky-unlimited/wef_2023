import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modals"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
    console.log("modal connected!");
  }

  display(event) {
    if (event.currentTarget.id !== "") {
      const target = this.modalTargets.find((modal) => {
        console.log(modal.id);
        console.log(modal.id === `${event.currentTarget.id}-modal`);
        return modal.id === `${event.currentTarget.id}-modal`;
      });
      console.log(target);
      target.style.display = "flex";
    } else {
      this.modalTarget.style.display = "flex";
    }
  }

  close(event) {
    event.preventDefault();
    this.modalTargets.forEach((modal) => {
      modal.style.display = "none";
    });
  }
}
