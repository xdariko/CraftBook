import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results", "tab", "section", "sectionTitle"];

  connect() {
    this.activeTab = "all";
    this.activateTabButton(this.activeTab);
    this.updateSectionTitlesVisibility();
    this.search();
  }

  search() {
    if (!this.hasInputTarget || !this.hasResultsTarget) return;

    const query = (this.inputTarget.value || "").toLowerCase();
    const activeTab = this.activeTab || "all";

    const items = this.resultsTarget.querySelectorAll("[data-item-name]");

    items.forEach((item) => {
      const itemName = (item.dataset.itemName || "").toLowerCase();
      const itemType = item.dataset.itemType || "";

      const showBySearch = query === "" || itemName.includes(query);
      const showByTab = activeTab === "all" || itemType === activeTab;

      item.style.display = showBySearch && showByTab ? "block" : "none";
    });

    ["ingredient", "recipe", "tag"].forEach((type) => {
      const section = this.sectionTargets.find((s) => s.dataset.itemType === type);
      if (!section) return;

      const sectionItems = section.querySelectorAll('[data-item-name]');
      const hasVisibleItems = Array.from(sectionItems).some(
        (el) => el.style.display !== "none"
      );

      section.style.display = hasVisibleItems ? "block" : "none";
    });
  }

  switchTab(event) {
    const btn = event.currentTarget;
    const type = btn.dataset.type || "all";

    this.activeTab = type;
    this.activateTabButton(type);
    this.updateSectionTitlesVisibility();
    this.search();
  }

  activateTabButton(type) {
    if (!this.hasTabTarget) return;

    this.tabTargets.forEach((btn) => {
      btn.dataset.active = (btn.dataset.type === type) ? "true" : "false";
    });
  }

  updateSectionTitlesVisibility() {
    if (!this.hasSectionTitleTarget) return;

    const showTitles = (this.activeTab === "all");

    this.sectionTitleTargets.forEach((title) => {
      title.style.display = showTitles ? "block" : "none";
    });

    this.sectionTargets.forEach((section) => {
      if (showTitles) {
        section.classList.remove("pt-1");
      } else {
        section.classList.add("pt-1");
      }
    });
  }
}
