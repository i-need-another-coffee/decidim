import { Controller } from "@hotwired/stimulus"
import createEditor from "src/decidim/editor";

export default class EditorController extends Controller {
  connect() {
    createEditor(this.element)
  }
}

