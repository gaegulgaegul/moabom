import { Controller } from "@hotwired/stimulus"

/**
 * Child Tag Controller
 * 아이 태그 선택 컨트롤러 - 사진 업로드 시 아이 선택 UI
 *
 * 주요 기능:
 * - 라디오 버튼 스타일의 단일 선택 UI
 * - 키보드 접근성 지원 (화살표 키, Enter, Space)
 * - ARIA 속성 자동 관리
 *
 * Usage:
 *   <div data-controller="child-tag">
 *     <button data-child-tag-target="button" data-child-id="1"
 *             data-action="click->child-tag#select keydown->child-tag#handleKeydown">
 *       아이 이름
 *     </button>
 *     <input type="hidden" data-child-tag-target="input" name="photo[child_id]">
 *   </div>
 */
export default class extends Controller {
  static targets = ["button", "input"]

  select(event) {
    const clickedButton = event.currentTarget
    this.setSelected(clickedButton)
  }

  handleKeydown(event) {
    const currentButton = event.currentTarget
    const currentIndex = this.buttonTargets.indexOf(currentButton)

    switch (event.key) {
      case "ArrowLeft":
      case "ArrowUp":
        event.preventDefault()
        this.focusPrevious(currentIndex)
        break
      case "ArrowRight":
      case "ArrowDown":
        event.preventDefault()
        this.focusNext(currentIndex)
        break
      case " ":
      case "Enter":
        event.preventDefault()
        this.setSelected(currentButton)
        break
    }
  }

  setSelected(button) {
    const childId = button.dataset.childId

    // Set the hidden input value
    this.inputTarget.value = childId

    // Update all buttons
    this.buttonTargets.forEach(btn => {
      const isSelected = btn === button

      // Update ARIA state
      btn.setAttribute("aria-checked", isSelected.toString())

      // Update visual classes
      if (isSelected) {
        btn.classList.remove("bg-cream-100", "text-warm-gray-600")
        btn.classList.add("bg-primary-500", "text-white")
      } else {
        btn.classList.remove("bg-primary-500", "text-white")
        btn.classList.add("bg-cream-100", "text-warm-gray-600")
      }
    })
  }

  focusPrevious(currentIndex) {
    const previousIndex = currentIndex > 0 ? currentIndex - 1 : this.buttonTargets.length - 1
    this.buttonTargets[previousIndex].focus()
  }

  focusNext(currentIndex) {
    const nextIndex = currentIndex < this.buttonTargets.length - 1 ? currentIndex + 1 : 0
    this.buttonTargets[nextIndex].focus()
  }
}
