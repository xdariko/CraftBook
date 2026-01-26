import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"];

  connect() {
    this.menuTarget.classList.add('hidden');
  }

  toggleMenu() {
    this.menuTarget.classList.toggle('hidden');
    this.menuTarget.classList.toggle('block');
  }
}
