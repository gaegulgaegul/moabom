# frozen_string_literal: true

module Home2Helper
  # 사진의 이미지 URL을 반환 (데모/실제 이미지 모두 지원)
  def photo_image_url(photo)
    if photo.respond_to?(:demo_image_url) && photo.demo_image_url.present?
      photo.demo_image_url
    elsif photo.respond_to?(:image) && photo.image.respond_to?(:attached?) && photo.image.attached?
      url_for(photo.image.variant(:thumbnail))
    else
      # 플레이스홀더 이미지
      "https://picsum.photos/seed/placeholder/300/300"
    end
  end
end
