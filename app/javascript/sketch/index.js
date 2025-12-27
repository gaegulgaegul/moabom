/**
 * Frame0 Sketch Style Utilities
 * Hand-drawn wireframe aesthetic using Rough.js
 */

import rough from "roughjs"

// Sketch configuration defaults
const SKETCH_CONFIG = {
  roughness: 1.5,
  bowing: 1,
  stroke: "#1A1A1A",
  strokeWidth: 1.5,
  fill: "transparent",
  fillStyle: "hachure",
  fillWeight: 0.5,
  hachureAngle: -41,
  hachureGap: 4,
  curveStepCount: 9,
  curveFitting: 0.95,
  lineCap: "round",
  lineJoin: "round"
}

/**
 * Create a Rough.js canvas wrapper
 * @param {HTMLCanvasElement|SVGSVGElement} element - Target element
 * @param {Object} options - Rough.js options
 * @returns {Object} Rough.js drawable
 */
export function createSketchCanvas(element, options = {}) {
  const config = { ...SKETCH_CONFIG, ...options }
  return rough.canvas(element, config)
}

/**
 * Create a Rough.js SVG wrapper
 * @param {SVGSVGElement} svg - Target SVG element
 * @param {Object} options - Rough.js options
 * @returns {Object} Rough.js drawable
 */
export function createSketchSVG(svg, options = {}) {
  const config = { ...SKETCH_CONFIG, ...options }
  return rough.svg(svg, config)
}

/**
 * Draw a sketch-style rectangle
 */
export function sketchRect(rc, x, y, width, height, options = {}) {
  return rc.rectangle(x, y, width, height, { ...SKETCH_CONFIG, ...options })
}

/**
 * Draw a sketch-style circle
 */
export function sketchCircle(rc, x, y, diameter, options = {}) {
  return rc.circle(x, y, diameter, { ...SKETCH_CONFIG, ...options })
}

/**
 * Draw a sketch-style line
 */
export function sketchLine(rc, x1, y1, x2, y2, options = {}) {
  return rc.line(x1, y1, x2, y2, { ...SKETCH_CONFIG, ...options })
}

/**
 * Apply sketch border to an HTML element using canvas overlay
 */
export function applySketchBorder(element, options = {}) {
  const rect = element.getBoundingClientRect()
  const canvas = document.createElement("canvas")

  canvas.width = rect.width + 4
  canvas.height = rect.height + 4
  canvas.style.position = "absolute"
  canvas.style.top = "-2px"
  canvas.style.left = "-2px"
  canvas.style.pointerEvents = "none"
  canvas.style.zIndex = "1"

  const rc = rough.canvas(canvas)
  rc.rectangle(2, 2, rect.width, rect.height, {
    ...SKETCH_CONFIG,
    ...options,
    fill: "transparent"
  })

  // Only set position to "relative" if the element has no positioning (static)
  // Check computed style to respect existing stylesheet rules
  const computedPosition = getComputedStyle(element).position
  if (computedPosition === "static") {
    element.style.position = "relative"
  }
  element.appendChild(canvas)

  return canvas
}

/**
 * Create an SVG filter element using safe DOM methods
 */
function createFilter(id, contents) {
  const NS = "http://www.w3.org/2000/svg"
  const filter = document.createElementNS(NS, "filter")
  filter.setAttribute("id", id)
  contents.forEach(child => filter.appendChild(child))
  return filter
}

/**
 * Create feTurbulence element
 */
function createTurbulence(type, baseFreq, octaves, result) {
  const NS = "http://www.w3.org/2000/svg"
  const el = document.createElementNS(NS, "feTurbulence")
  el.setAttribute("type", type)
  el.setAttribute("baseFrequency", baseFreq)
  el.setAttribute("numOctaves", octaves)
  if (result) el.setAttribute("result", result)
  return el
}

/**
 * Create feDisplacementMap element
 */
function createDisplacementMap(inAttr, in2, scale, xChannel, yChannel) {
  const NS = "http://www.w3.org/2000/svg"
  const el = document.createElementNS(NS, "feDisplacementMap")
  el.setAttribute("in", inAttr)
  if (in2) el.setAttribute("in2", in2)
  el.setAttribute("scale", scale)
  if (xChannel) el.setAttribute("xChannelSelector", xChannel)
  if (yChannel) el.setAttribute("yChannelSelector", yChannel)
  return el
}

/**
 * Create SVG filters for sketch effects using safe DOM methods
 */
export function createSketchFilters() {
  const NS = "http://www.w3.org/2000/svg"
  const svg = document.createElementNS(NS, "svg")
  svg.setAttribute("class", "sketch-filters")
  svg.style.position = "absolute"
  svg.style.width = "0"
  svg.style.height = "0"
  svg.style.overflow = "hidden"

  const defs = document.createElementNS(NS, "defs")

  // Roughen filter
  defs.appendChild(createFilter("roughen-filter", [
    createTurbulence("turbulence", "0.02", "3", "noise"),
    createDisplacementMap("SourceGraphic", "noise", "2", "R", "G")
  ]))

  // Sketch wobble filter
  defs.appendChild(createFilter("sketch-wobble", [
    createTurbulence("turbulence", "0.04", "2", "noise"),
    createDisplacementMap("SourceGraphic", "noise", "1.5", null, null)
  ]))

  // Pencil texture filter
  defs.appendChild(createFilter("pencil-texture", [
    createTurbulence("fractalNoise", "1.2", "2", null),
    createDisplacementMap("SourceGraphic", null, "1", null, null)
  ]))

  svg.appendChild(defs)
  return svg
}

/**
 * Initialize sketch environment
 */
export function initSketchEnvironment() {
  if (!document.getElementById("sketch-filters-svg")) {
    const filters = createSketchFilters()
    filters.id = "sketch-filters-svg"
    document.body.insertBefore(filters, document.body.firstChild)
  }
}

// Export configuration
export { SKETCH_CONFIG }

// Export Rough.js for direct access
export { rough }
