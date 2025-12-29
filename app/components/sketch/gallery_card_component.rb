# frozen_string_literal: true

module Sketch
  # Sketch 스타일 갤러리 카드 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 콜라주/벤토 그리드 이미지 레이아웃 카드
  #
  # 주요 기능:
  # - 메인/보조/세 번째 이미지 슬롯 지원
  # - 추가 사진 개수 오버레이 표시
  # - 다양한 종횡비 지원 (square, landscape, portrait)
  # - 호버/클릭 인터랙션
  #
  # @param variant [Symbol] 카드 스타일 (:default)
  # @param aspect_ratio [Symbol] 종횡비 (:square, :landscape, :portrait)
  # @param hoverable [Boolean] 호버 효과 활성화
  # @param href [String] 링크 URL
  #
  # @example 기본 사용 (3개 이미지)
  #   render Sketch::GalleryCardComponent.new do |card|
  #     card.with_main_image(src: "photo1.jpg", alt: "메인 사진")
  #     card.with_secondary_image(src: "photo2.jpg", alt: "두 번째 사진")
  #     card.with_tertiary_image(src: "photo3.jpg", alt: "세 번째 사진", more_count: 5)
  #   end
  class GalleryCardComponent < BaseComponent
    renders_one :main_image, ->(src:, alt: "", **options) do
      tag.div(class: "relative w-full h-full overflow-hidden") do
        tag.img(src: src, alt: alt, class: "w-full h-full object-cover", **options)
      end
    end

    renders_one :secondary_image, ->(src:, alt: "", **options) do
      tag.div(class: "relative w-full h-full overflow-hidden") do
        tag.img(src: src, alt: alt, class: "w-full h-full object-cover", **options)
      end
    end

    renders_one :tertiary_image, ->(src:, alt: "", more_count: nil, more_text: nil, **options) do
      tag.div(class: "relative w-full h-full overflow-hidden") do
        safe_join([
          tag.img(src: src, alt: alt, class: "w-full h-full object-cover", **options),
          if more_count.present? || more_text.present?
            overlay_text = more_text || "+#{more_count} 더보기"
            tag.div(class: "absolute inset-0 bg-sketch-overlay-medium flex items-center justify-center") do
              tag.span(overlay_text, class: "text-white font-sketch text-lg font-semibold")
            end
          end
        ].compact)
      end
    end

    def initialize(variant: :default, aspect_ratio: :landscape, hoverable: false, href: nil, **options)
      @variant = variant
      @aspect_ratio = aspect_ratio
      @hoverable = hoverable
      @href = href
      super(**options)
    end

    def card_classes
      base = [
        base_classes,
        "bg-sketch-paper",
        "border-2 border-sketch-ink",
        "rounded-sketch-lg",
        "overflow-hidden",
        @hoverable ? "hover:shadow-sketch-lg hover:-translate-y-1 cursor-pointer transition-all duration-200" : ""
      ]
      base.compact.join(" ")
    end

    def grid_height_class
      case @aspect_ratio
      when :square then "h-64"
      when :landscape then "h-48"
      when :portrait then "h-72"
      else "h-48"
      end
    end

    def card_data
      stimulus_data("card", {
        "sketch-card-hoverable-value": @hoverable,
        action: @hoverable ? "mouseenter->sketch-card#onHover mouseleave->sketch-card#onLeave" : ""
      })
    end

    def wrapper_tag
      @href.present? ? :a : :div
    end

    def wrapper_options
      opts = { class: card_classes, data: card_data }
      opts[:href] = @href if @href.present?
      opts
    end

    def has_images?
      main_image.present? || secondary_image.present? || tertiary_image.present?
    end
  end
end
