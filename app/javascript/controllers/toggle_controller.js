import { Controller } from "@hotwired/stimulus"

// 토글 스위치 컨트롤러
// Usage:
//   <button data-controller="toggle"
//           data-toggle-active="true"
//           data-action="click->toggle#toggle">
//     <span data-toggle-target="knob"></span>
//   </button>
export default class extends Controller {
  static targets = ["knob"]
  static values = {
    active: { type: Boolean, default: false }
  }

  connect() {
    // data-toggle-active 속성에서 초기 상태 읽기
    const initialActive = this.element.dataset.toggleActive === "true"
    this.activeValue = initialActive
    this.updateUI()
  }

  toggle(event) {
    event.preventDefault()
    this.activeValue = !this.activeValue
    this.updateUI()
  }

  activeValueChanged() {
    this.updateUI()
  }

  updateUI() {
    if (this.activeValue) {
      // ON 상태
      this.element.classList.remove("bg-warm-gray-200")
      this.element.classList.add("bg-primary-500")
      
      if (this.hasKnobTarget) {
        this.knobTarget.classList.remove("left-1")
        this.knobTarget.classList.add("right-1")
      }
    } else {
      // OFF 상태
      this.element.classList.remove("bg-primary-500")
      this.element.classList.add("bg-warm-gray-200")
      
      if (this.hasKnobTarget) {
        this.knobTarget.classList.remove("right-1")
        this.knobTarget.classList.add("left-1")
      }
    }
  }
}
