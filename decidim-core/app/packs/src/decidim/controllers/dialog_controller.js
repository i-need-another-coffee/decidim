import { Controller } from "@hotwired/stimulus"
import { createDialog } from "src/decidim/a11y"


export default class DialogController extends Controller {
  connect() {
    createDialog(this.element)
  }
}

