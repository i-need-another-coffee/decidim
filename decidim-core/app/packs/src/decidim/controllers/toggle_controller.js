import { Controller } from "@hotwired/stimulus"
import createToggle from "src/decidim/toggle"

export default class ToggleController extends Controller {
  connect() {
    createToggle(this.element)
  }
}

