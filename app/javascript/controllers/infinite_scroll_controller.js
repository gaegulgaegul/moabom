import { Controller } from "@hotwired/stimulus"

/**
 * Infinite Scroll Controller
 * 무한 스크롤 컨트롤러 - IntersectionObserver를 사용하여 페이지네이션 자동 로드
 *
 * 주요 기능:
 * - 페이지네이션 요소가 뷰포트에 진입하면 다음 페이지 자동 로드
 * - Turbo Stream 응답을 사용한 동적 콘텐츠 추가
 * - 로딩 상태 및 더 이상 데이터 없음 상태 관리
 *
 * Usage:
 *   <div data-controller="infinite-scroll"
 *        data-infinite-scroll-url-value="/photos"
 *        data-infinite-scroll-has-more-value="true">
 *     <div data-infinite-scroll-target="entries">콘텐츠</div>
 *     <div data-infinite-scroll-target="pagination">로딩...</div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = {
    url: String,
    page: { type: Number, default: 1 },
    hasMore: { type: Boolean, default: true }
  }

  connect() {
    this.isLoading = false
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
    if (!this.hasMoreValue || this.isLoading) return

    this.isLoading = true

    const nextPage = this.pageValue + 1
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("page", nextPage)

    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
        this.pageValue = nextPage
        this.updateHasMore()
      }
    } catch (error) {
      console.error("Failed to load more:", error)
    } finally {
      this.isLoading = false
    }
  }

  updateHasMore() {
    const hasMoreFlag = document.getElementById("infinite-scroll-has-more")
    if (hasMoreFlag) {
      const hasMore = hasMoreFlag.dataset.hasMore === "true"
      this.hasMoreValue = hasMore

      if (!hasMore && this.hasPaginationTarget) {
        this.observer.unobserve(this.paginationTarget)
      }
    }
  }
}
