import { Controller } from "@hotwired/stimulus"
import createEditor from "src/decidim/editor";

export default class DropdownController extends Controller {
  connect() {
    createEditor(this.element)
  }
}

