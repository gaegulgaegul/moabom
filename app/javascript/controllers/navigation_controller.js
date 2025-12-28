import { Controller } from "@hotwired/stimulus"

// 네비게이션 컨트롤러
// Usage:
//   <button
//     data-controller="navigation"
//     data-action="click->navigation#goToInvite"
//     data-navigation-invite-path-value="/onboarding/invite">
//     나중에 할게요
//   </button>
export default class extends Controller {
  static values = {
    invitePath: String
  }

  goToInvite(event) {
    event.preventDefault()

    // Use Turbo for navigation if available, otherwise standard redirect
    const path = this.invitePathValue || "/onboarding/invite"

    if (window.Turbo) {
      window.Turbo.visit(path)
    } else {
      window.location.href = path
    }
  }
}
