import { Controller } from "@hotwired/stimulus"
import createTooltip from "src/decidim/tooltips"

export default class TooltipController extends Controller {
  connect() {
    createTooltip(this.element)
  }
}

