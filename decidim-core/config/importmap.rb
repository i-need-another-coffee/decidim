# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap
enable_integrity!

pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "decidim", to: "decidim.js"
pin_all_from Decidim::Core::Engine.root.join("app/javascript/controllers"), under: "controllers"
