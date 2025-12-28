import { Controller } from "@hotwired/stimulus"

// Story Filter Controller
// 스토리 스타일 아이 프로필 필터의 가로 스크롤 및 선택 상태 관리
export default class extends Controller {
  connect() {
    // 선택된 아이템이 있으면 스크롤하여 보이게 함
    this.scrollToSelected()
  }

  scrollToSelected() {
    const selected = this.element.querySelector('.story-avatar-ring--selected')
    if (selected) {
      const container = this.element
      const selectedParent = selected.closest('.story-avatar')
      if (selectedParent) {
        // 선택된 아이템을 중앙에 위치시킴
        const containerWidth = container.offsetWidth
        const itemLeft = selectedParent.offsetLeft
        const itemWidth = selectedParent.offsetWidth
        const scrollLeft = itemLeft - (containerWidth / 2) + (itemWidth / 2)

        container.scrollTo({
          left: Math.max(0, scrollLeft),
          behavior: 'smooth'
        })
      }
    }
  }
}
