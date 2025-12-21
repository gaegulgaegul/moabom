import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = {
    url: String,
    page: { type: Number, default: 1 },
    hasMore: { type: Boolean, default: true }
  }

  connect() {
    this.observer = new IntersectionObserver(
      entries => this.handleIntersect(entries),
      { threshold: 0.1 }
    )

    if (this.hasPaginationTarget && this.hasMoreValue) {
      this.observer.observe(this.paginationTarget)
    }
  }

  disconnect() {
    this.observer.disconnect()
  }

  handleIntersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && this.hasMoreValue) {
        this.loadMore()
      }
    })
  }

  async loadMore() {
    if (!this.hasMoreValue) return

    this.pageValue += 1

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("page", this.pageValue)

    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Failed to load more:", error)
    }
  }
}
