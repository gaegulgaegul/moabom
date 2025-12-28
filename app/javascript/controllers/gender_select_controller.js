import { Controller } from "@hotwired/stimulus"

// 성별 선택 컨트롤러
// Usage:
//   <div data-controller="gender-select">
//     <button data-gender-select-target="female" data-action="click->gender-select#selectFemale">여아</button>
//     <button data-gender-select-target="male" data-action="click->gender-select#selectMale">남아</button>
//     <input type="hidden" data-gender-select-target="input" />
//   </div>
export default class extends Controller {
  static targets = ["female", "male", "input"]

  connect() {
    // Initialize with current value
    const currentValue = this.inputTarget.value || "female"
    this.selectGender(currentValue)
  }

  selectFemale(event) {
    event?.preventDefault()
    this.inputTarget.value = "female"
    this.selectGender("female")
  }

  selectMale(event) {
    event?.preventDefault()
    this.inputTarget.value = "male"
    this.selectGender("male")
  }

  selectGender(gender) {
    // Reset all buttons to inactive state
    this.femaleTarget.classList.remove("border-sketch-ink", "bg-sketch-cream", "text-sketch-ink")
    this.femaleTarget.classList.add("border-sketch-gray", "bg-transparent", "text-sketch-gray")
    this.maleTarget.classList.remove("border-sketch-ink", "bg-sketch-cream", "text-sketch-ink")
    this.maleTarget.classList.add("border-sketch-gray", "bg-transparent", "text-sketch-gray")

    // Set active state for selected button
    if (gender === "female") {
      this.femaleTarget.classList.remove("border-sketch-gray", "bg-transparent", "text-sketch-gray")
      this.femaleTarget.classList.add("border-sketch-ink", "bg-sketch-cream", "text-sketch-ink")
    } else if (gender === "male") {
      this.maleTarget.classList.remove("border-sketch-gray", "bg-transparent", "text-sketch-gray")
      this.maleTarget.classList.add("border-sketch-ink", "bg-sketch-cream", "text-sketch-ink")
    }
  }
}
