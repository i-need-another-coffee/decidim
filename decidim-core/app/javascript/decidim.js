// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

const application = Application.start()

// Configure Stimulus development experience
application.debug = true

eagerLoadControllersFrom("controllers", window.Stimulus)
