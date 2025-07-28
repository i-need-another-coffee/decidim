import { Controller } from "@hotwired/stimulus"
import { createDropdown } from "src/decidim/a11y"


export default class DropdownController extends Controller {
  connect() {
    createDropdown(this.element)
  }
}

