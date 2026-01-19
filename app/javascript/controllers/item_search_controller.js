import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  search() {
    const query = this.inputTarget.value.toLowerCase()
    const items = this.resultsTarget.querySelectorAll('[data-item-name]')

    items.forEach(item => {
      const itemName = item.dataset.itemName
      const itemType = item.dataset.itemType
      
      if (itemName.includes(query)) {
        item.style.display = 'block'
      } else {
        item.style.display = 'none'
      }
    })
  }
}