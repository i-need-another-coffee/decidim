import { Controller } from "@hotwired/stimulus"
import createEditor from "src/decidim/editor";

export default class extends Controller {
  connect() {

    const accordionParents = this.getParents(this.element, "[data-controller*='accordion']");

    if (accordionParents.length === 0) {
      this.initializeEditor();
    } else {
      accordionParents.forEach((accordionParent) => {
        let toggleButton = accordionParent.querySelector("[data-controls]");
        if (toggleButton) {
          toggleButton.addEventListener("click", () => {
            this.initializeEditor();
          });
        }
      })
    }
  }

  initializeEditor() {
    if (!this.element.dataset.editorInitialized) {
      this.editor = createEditor(this.element);
      this.element.dataset.editorInitialized = true;
    }
  }

  getParents(element, selector) {
    const parents = [];
    let current = element.parentElement;

    while (current) {
      // Check if the current parent matches the selector
      if (current.matches && current.matches(selector)) {
        parents.push(current);
      }
      current = current.parentElement;
    }

    return parents;
  }
}
