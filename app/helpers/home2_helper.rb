# frozen_string_literal: true

module Home2Helper
  # 사진의 이미지 URL을 반환
  def photo_image_url(photo)
    return url_for(photo.image.variant(:thumbnail)) if photo.image&.attached?

    # 플레이스홀더 이미지 (테스트 환경에서 이미지가 없는 경우)
    "https://picsum.photos/seed/#{photo.id}/300/300"
  end
end
