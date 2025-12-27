# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Frame0 Sketch Style Dependencies (CDN)
pin "roughjs", to: "https://cdn.jsdelivr.net/npm/roughjs@4.6.6/bundled/rough.esm.js"
pin "wired-elements", to: "https://cdn.jsdelivr.net/npm/wired-elements@3.0.0-rc.6/lib/wired-elements.js"
pin "stimulus-use", to: "https://cdn.jsdelivr.net/npm/stimulus-use@0.52.3/dist/index.js"

# Sketch utilities
pin_all_from "app/javascript/sketch", under: "sketch", preload: false
