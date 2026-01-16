import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    console.log("Tag Search controller connected")
  }

  search() {
    const searchTerm = this.inputTarget.value.toLowerCase().trim()
    const cards = this.resultsTarget.querySelectorAll('[data-tag-name]')
    
    cards.forEach(card => {
      const tagName = card.dataset.tagName.toLowerCase()
      if (tagName.includes(searchTerm) || searchTerm === "") {
        card.style.display = 'block'
      } else {
        card.style.display = 'none'
      }
    })
  }
}