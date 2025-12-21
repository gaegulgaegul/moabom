# frozen_string_literal: true

class Photo < ApplicationRecord
  MAX_FILE_SIZE = 50.megabytes
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/heic image/webp].freeze

  belongs_to :family
  belongs_to :uploader, class_name: "User"
  belongs_to :child, optional: true

  has_many :reactions, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :image do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 300, 300 ]
    attachable.variant :medium, resize_to_limit: [ 800, 800 ]
    attachable.variant :large, resize_to_limit: [ 1600, 1600 ]
  end

  validates :taken_at, presence: true
  validates :image, presence: true, unless: -> { Rails.env.test? }
  validate :acceptable_image

  scope :for_family, ->(family) { where(family: family) }
  scope :recent, -> { order(taken_at: :desc) }
  scope :with_eager_loaded_image, -> { includes(image_attachment: :blob) }
  scope :by_month, ->(year, month) {
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    where(taken_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  # 타임라인용 최적화 쿼리 (N+1 방지)
  scope :timeline_for, ->(family, page: 1, per_page: 50) {
    for_family(family)
      .recent
      .includes(:uploader, :child, image_attachment: :blob)
      .limit(per_page)
      .offset((page - 1) * per_page)
  }

  # 날짜별 그룹화 (최신순으로 정렬 후 그룹화)
  def self.group_by_date
    recent.group_by { |photo| photo.taken_at.to_date }
  end

  # 타임라인용 (날짜 헤더 + 사진)
  def self.timeline
    group_by_date.map do |date, photos|
      {
        date: date,
        photos: photos,
        count: photos.size
      }
    end
  end

  private

  def acceptable_image
    return unless image.attached?

    unless ALLOWED_CONTENT_TYPES.include?(image.blob.content_type)
      errors.add(:image, "허용되지 않는 파일 형식입니다. (허용: JPEG, PNG, HEIC, WebP)")
    end

    if image.blob.byte_size > MAX_FILE_SIZE
      errors.add(:image, "파일 크기가 50MB를 초과합니다.")
    end
  end
end
