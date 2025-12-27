import { Controller } from "@hotwired/stimulus"
import rough from "roughjs"

/**
 * Sketch Button Controller
 * Applies Rough.js hand-drawn border effect with hover animations
 *
 * Usage:
 *   <button data-controller="sketch-button"
 *           data-sketch-button-roughness-value="1.5"
 *           data-sketch-button-seed-value="42">
 *     Click me
 *   </button>
 */
export default class extends Controller {
  static targets = ["border"]
  static values = {
    roughness: { type: Number, default: 1.5 },
    seed: { type: Number, default: 42 },
    variant: { type: String, default: "primary" }
  }

  connect() {
    this.isHovering = false
    this.animationFrame = null
    this.drawBorder()
  }

  disconnect() {
    this.cancelAnimation()
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
    const strokeColor = this.getStrokeColor()
    const dashPattern = this.getRandomDashPattern()

    const border = rc.rectangle(1, 1, rect.width - 2, rect.height - 2, {
      roughness: this.roughnessValue,
      stroke: strokeColor,
      strokeWidth: 1.5,
      bowing: 1,
      seed: this.seedValue,
      strokeLineDash: dashPattern
    })

    svg.appendChild(border)

    if (this.hasBorderTarget) {
      this.clearBorderTarget()
      this.borderTarget.appendChild(svg)
    }

    this.svg = svg
  }

  redrawBorder(roughnessOffset = 0) {
    const rect = this.element.getBoundingClientRect()

    if (!this.svg) return

    const rc = rough.svg(this.svg)
    const strokeColor = this.getStrokeColor()
    const dashPattern = this.getRandomDashPattern()

    // Clear SVG children using safe DOM methods
    while (this.svg.firstChild) {
      this.svg.removeChild(this.svg.firstChild)
    }

    const border = rc.rectangle(1, 1, rect.width - 2, rect.height - 2, {
      roughness: this.roughnessValue + roughnessOffset,
      stroke: strokeColor,
      strokeWidth: this.isHovering ? 2 : 1.5,
      bowing: this.isHovering ? 1.5 : 1,
      seed: this.seedValue + (this.isHovering ? Math.random() * 10 : 0),
      strokeLineDash: dashPattern
    })

    this.svg.appendChild(border)
  }

  onHover() {
    if (this.element.disabled) return

    this.isHovering = true
    this.element.classList.add("sketch-wobble")
    this.startWobbleAnimation()
  }

  onLeave() {
    this.isHovering = false
    this.element.classList.remove("sketch-wobble")
    this.cancelAnimation()
    this.redrawBorder()
  }

  startWobbleAnimation() {
    let frame = 0
    const animate = () => {
      if (!this.isHovering) return

      frame++
      const wobble = Math.sin(frame * 0.2) * 0.3
      this.redrawBorder(wobble)

      this.animationFrame = requestAnimationFrame(animate)
    }
    animate()
  }

  cancelAnimation() {
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame)
      this.animationFrame = null
    }
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

  getStrokeColor() {
    const colors = {
      primary: "#1A1A1A",
      secondary: "#6B7280",
      ghost: "#9CA3AF",
      danger: "#DC2626"
    }
    return colors[this.variantValue] || colors.primary
  }

  getRandomDashPattern() {
    const patterns = [
      [4, 3],
      [5, 2],
      [3, 4],
      [6, 2, 2, 2],
      [8, 3]
    ]
    return patterns[Math.floor(Math.random() * patterns.length)]
  }

  // Handle window resize
  resize() {
    this.drawBorder()
  }
}
