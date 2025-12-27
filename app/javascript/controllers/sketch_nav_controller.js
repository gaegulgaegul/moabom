import { Controller } from "@hotwired/stimulus"
import rough from "roughjs"

/**
 * Sketch Navigation Controller
 * Applies Rough.js hand-drawn border effect to navigation elements
 */
export default class extends Controller {
  static targets = ["border"]
  static values = {
    roughness: { type: Number, default: 1.2 },
    variant: { type: String, default: "header" }
  }

  connect() {
    this.drawBorder()
    this.resizeObserver = new ResizeObserver(() => this.drawBorder())
    this.resizeObserver.observe(this.element)
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    this.removeBorder()
  }

  drawBorder() {
    const rect = this.element.getBoundingClientRect()
    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")

    svg.setAttribute("width", rect.width)
    svg.setAttribute("height", rect.height)
    svg.style.position = "absolute"
    svg.style.top = "0"
    svg.style.left = "0"
    svg.style.pointerEvents = "none"
    svg.style.overflow = "visible"

    const rc = rough.svg(svg)

    // Draw border line based on variant
    if (this.variantValue === "header") {
      // Bottom border for header
      const line = rc.line(0, rect.height - 1, rect.width, rect.height - 1, {
        roughness: this.roughnessValue,
        stroke: "#1A1A1A",
        strokeWidth: 2,
        bowing: 0.5
      })
      svg.appendChild(line)
    } else if (this.variantValue === "tabbar") {
      // Top border for tabbar
      const line = rc.line(0, 1, rect.width, 1, {
        roughness: this.roughnessValue,
        stroke: "#1A1A1A",
        strokeWidth: 2,
        bowing: 0.5
      })
      svg.appendChild(line)
    } else if (this.variantValue === "sidebar") {
      // Right border for sidebar
      const line = rc.line(rect.width - 1, 0, rect.width - 1, rect.height, {
        roughness: this.roughnessValue,
        stroke: "#1A1A1A",
        strokeWidth: 2,
        bowing: 0.5
      })
      svg.appendChild(line)
    }

    if (this.hasBorderTarget) {
      this.clearBorderTarget()
      this.borderTarget.appendChild(svg)
    }

    this.svg = svg
  }

  clearBorderTarget() {
    while (this.borderTarget.firstChild) {
      this.borderTarget.removeChild(this.borderTarget.firstChild)
    }
  }

  removeBorder() {
    if (this.hasBorderTarget) {
      this.clearBorderTarget()
    }
  }
}
