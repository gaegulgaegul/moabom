import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["placeholder", "preview"]

  preview(event) {
    const file = event.target.files[0]

    if (!file) {
      this.showPlaceholder()
      return
    }

    if (!file.type.startsWith('image/')) {
      alert('이미지 파일만 선택 가능합니다.')
      event.target.value = ''
      this.showPlaceholder()
      return
    }

    const reader = new FileReader()

    reader.onload = (e) => {
      this.previewTarget.src = e.target.result
      this.hidePlaceholder()
      this.showPreview()
    }

    reader.onerror = () => {
      alert('이미지를 불러올 수 없습니다.')
      this.showPlaceholder()
    }

    reader.readAsDataURL(file)
  }

  showPlaceholder() {
    this.placeholderTarget.classList.remove('hidden')
    this.previewTarget.classList.add('hidden')
  }

  hidePlaceholder() {
    this.placeholderTarget.classList.add('hidden')
  }

  showPreview() {
    this.previewTarget.classList.remove('hidden')
  }
}
