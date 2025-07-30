import { Controller } from "@hotwired/stimulus"
import { createAccordion } from "src/decidim/a11y"


export default class AccordionController extends Controller {
  connect() {
    createAccordion(this.element)
  }
}

