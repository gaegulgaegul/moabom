import { Controller } from "@hotwired/stimulus"

/**
 * Image Preview Controller
 * 이미지 미리보기 컨트롤러 - 파일 선택 시 이미지 미리보기 표시
 *
 * 주요 기능:
 * - 파일 선택 시 FileReader로 이미지 로드
 * - 이미지 파일 타입 검증
 * - placeholder와 preview 토글 표시
 *
 * Usage:
 *   <div data-controller="image-preview">
 *     <input type="file" data-action="change->image-preview#preview" accept="image/*">
 *     <div data-image-preview-target="placeholder">이미지를 선택하세요</div>
 *     <img data-image-preview-target="preview" class="hidden">
 *   </div>
 */
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
