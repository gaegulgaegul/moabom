# frozen_string_literal: true

module PhotoTestHelpers
  # 테스트용 사진 생성 헬퍼
  def create_test_photo(family:, uploader:, attributes: {})
    photo = family.photos.build(attributes.merge(
      uploader: uploader,
      taken_at: attributes[:taken_at] || Time.current
    ))

    # 테스트 이미지 파일 첨부 (블록 형식으로 파일 핸들 자동 닫기)
    File.open(Rails.root.join("test/fixtures/files/photo.jpg")) do |file|
      photo.image.attach(
        io: file,
        filename: "photo.jpg",
        content_type: "image/jpeg"
      )
      photo.save!
    end

    photo
  end

  # 픽스처 사진에 이미지 첨부
  def attach_images_to_fixture_photos
    Photo.find_each do |photo|
      next if photo.image.attached?

      File.open(Rails.root.join("test/fixtures/files/photo.jpg")) do |file|
        photo.image.attach(
          io: file,
          filename: "photo.jpg",
          content_type: "image/jpeg"
        )
      end
    end
  end
end
