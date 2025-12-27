import { Controller } from "@hotwired/stimulus"
import { applySketchBorder } from "sketch/index"

/**
 * Sketch Border Controller
 * Applies hand-drawn border effect to elements using Rough.js
 *
 * Usage:
 *   <div data-controller="sketch-border"
 *        data-sketch-border-roughness-value="1.5"
 *        data-sketch-border-stroke-value="#1A1A1A">
 *     Content
 *   </div>
 */
export default class extends Controller {
  static values = {
    roughness: { type: Number, default: 1.5 },
    stroke: { type: String, default: "#1A1A1A" },
    strokeWidth: { type: Number, default: 1.5 },
    bowing: { type: Number, default: 1 }
  }

  connect() {
    this.canvas = null
    this.applyBorder()
  }

  disconnect() {
    this.removeBorder()
  }

  applyBorder() {
    this.canvas = applySketchBorder(this.element, {
      roughness: this.roughnessValue,
      stroke: this.strokeValue,
      strokeWidth: this.strokeWidthValue,
      bowing: this.bowingValue
    })
  }

  removeBorder() {
    if (this.canvas && this.canvas.parentNode) {
      this.canvas.parentNode.removeChild(this.canvas)
    }
  }

  // Redraw on window resize
  resize() {
    this.removeBorder()
    this.applyBorder()
  }
}
