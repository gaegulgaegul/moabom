import { Controller } from "@hotwired/stimulus"

// Direct Upload 에러 처리 컨트롤러
export default class extends Controller {
  static targets = ["input", "error", "progress"]

  connect() {
    this.element.addEventListener("direct-upload:initialize", this.initialize.bind(this))
    this.element.addEventListener("direct-upload:start", this.start.bind(this))
    this.element.addEventListener("direct-upload:progress", this.progress.bind(this))
    this.element.addEventListener("direct-upload:error", this.error.bind(this))
    this.element.addEventListener("direct-upload:end", this.end.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("direct-upload:initialize", this.initialize.bind(this))
    this.element.removeEventListener("direct-upload:start", this.start.bind(this))
    this.element.removeEventListener("direct-upload:progress", this.progress.bind(this))
    this.element.removeEventListener("direct-upload:error", this.error.bind(this))
    this.element.removeEventListener("direct-upload:end", this.end.bind(this))
  }

  initialize(event) {
    this.hideError()
    if (this.hasProgressTarget) {
      this.progressTarget.classList.remove("hidden")
      this.progressTarget.style.width = "0%"
    }
  }

  start(event) {
    if (this.hasProgressTarget) {
      this.progressTarget.classList.remove("hidden")
    }
  }

  progress(event) {
    const { progress } = event.detail
    if (this.hasProgressTarget) {
      this.progressTarget.style.width = `${progress}%`
    }
  }

  error(event) {
    event.preventDefault()
    const { error } = event.detail

    // 에러 메시지 표시
    this.showError(this.getErrorMessage(error))

    // 진행률 숨기기
    if (this.hasProgressTarget) {
      this.progressTarget.classList.add("hidden")
    }
  }

  end(event) {
    if (this.hasProgressTarget) {
      this.progressTarget.style.width = "100%"
      setTimeout(() => {
        this.progressTarget.classList.add("hidden")
      }, 500)
    }
  }

  retry() {
    this.hideError()
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.click()
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
      this.errorTarget.textContent = ""
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove("hidden")
    }
  }

  getErrorMessage(error) {
    // 에러 유형에 따른 사용자 친화적 메시지
    if (error.includes("network") || error.includes("Network")) {
      return "네트워크 오류가 발생했습니다. 인터넷 연결을 확인하고 다시 시도해주세요."
    }
    if (error.includes("timeout") || error.includes("Timeout")) {
      return "업로드 시간이 초과되었습니다. 파일 크기를 확인하고 다시 시도해주세요."
    }
    if (error.includes("size") || error.includes("large")) {
      return "파일 크기가 너무 큽니다. 50MB 이하의 파일을 선택해주세요."
    }
    return `업로드 중 오류가 발생했습니다: ${error}`
  }
}
