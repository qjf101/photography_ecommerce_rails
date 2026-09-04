import { Controller } from "@hotwired/stimulus"

// Packs variable-height cards (product photos of different orientations)
// into even columns without the trailing gaps CSS multi-column layout
// leaves when an item doesn't fit the remaining space in a column.
export default class extends Controller {
  static targets = ["item"]
  static values = { gap: { type: Number, default: 20 } }

  connect() {
    this.element.classList.add("js-masonry")

    this.handleResize = this.debounce(() => this.layout(), 100)
    window.addEventListener("resize", this.handleResize)

    const images = this.itemTargets
      .map((item) => item.querySelector("img"))
      .filter((img) => img && !img.complete)

    images.forEach((img) => {
      img.addEventListener("load", () => this.layout(), { once: true })
      img.addEventListener("error", () => this.layout(), { once: true })
    })

    this.layout()
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
  }

  layout() {
    if (this.itemTargets.length === 0) return

    const gap = this.gapValue
    const width = this.element.clientWidth
    const columns = width < 560 ? 1 : width < 900 ? 2 : 3
    const columnWidth = (width - gap * (columns - 1)) / columns
    const columnHeights = new Array(columns).fill(0)

    this.itemTargets.forEach((item) => {
      item.style.width = `${columnWidth}px`

      const columnIndex = columnHeights.indexOf(Math.min(...columnHeights))
      const x = columnIndex * (columnWidth + gap)
      const y = columnHeights[columnIndex]
      item.style.transform = `translate(${x}px, ${y}px)`

      columnHeights[columnIndex] += item.offsetHeight + gap
    })

    this.element.style.height = `${Math.max(...columnHeights) - gap}px`
  }

  debounce(fn, wait) {
    let timeout
    return (...args) => {
      clearTimeout(timeout)
      timeout = setTimeout(() => fn(...args), wait)
    }
  }
}
