import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notice"];

  connect() {
    console.log("Alerts connected!");
    this.myTimeOut1 = setTimeout(() => {
      this.fadeOut();
    }, 5000);
  }

  fadeOut() {
    this.noticeTarget.classList.add("alert-fadeout");
    this.myTimeOut2 = setTimeout(() => {
      this.closeAfterFadeOut();
    }, 2000);
  }

  close() {
    clearTimeout(this.myTimeOut1);
    clearTimeout(this.myTimeOut2);
    this.noticeTarget.parentNode.removeChild(this.noticeTarget);
  }

  closeAfterFadeOut() {
    if (this.noticeTarget.classList.contains("alert-fadeout")) {
      this.noticeTarget.parentNode.removeChild(this.noticeTarget);
    }
  }
}
