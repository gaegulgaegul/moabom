// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Frame0 Sketch Style Environment
import { initSketchEnvironment, rough } from "sketch/index"

// Initialize sketch SVG filters on DOM ready
document.addEventListener("DOMContentLoaded", () => {
  initSketchEnvironment()
})

// Also initialize on Turbo page loads
document.addEventListener("turbo:load", () => {
  initSketchEnvironment()
})

// Expose Rough.js globally for debugging/console use
if (typeof window !== "undefined") {
  window.rough = rough
}
