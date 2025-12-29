# frozen_string_literal: true

module Sketch
  # Sketch 스타일 카드 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 카드
  #
  # 주요 기능:
  # - 다양한 카드 스타일 (default, elevated, flat, glass)
  # - 헤더/푸터/이미지 슬롯 지원
  # - 호버/클릭 인터랙션
  # - RoughJS 기반 스케치 테두리
  #
  # @param variant [Symbol] 카드 스타일 (:default, :elevated, :flat, :glass)
  # @param padding [Symbol] 내부 여백 (:none, :sm, :md, :lg)
  # @param hoverable [Boolean] 호버 효과 활성화
  # @param clickable [Boolean] 클릭 가능 상태
  # @param href [String] 링크 URL
  #
  # @example 기본 사용
  #   render Sketch::CardComponent.new { "카드 내용" }
  class CardComponent < BaseComponent
    VARIANTS = {
      default: {
        bg: "bg-sketch-paper",
        border: "border-sketch-ink",
        shadow: ""
      },
      elevated: {
        bg: "bg-sketch-paper",
        border: "border-sketch-ink",
        shadow: "shadow-sketch-md"
      },
      flat: {
        bg: "bg-sketch-cream",
        border: "border-sketch-gray",
        shadow: ""
      },
      glass: {
        bg: "bg-white/70 backdrop-blur-md",
        border: "border-white/20",
        shadow: "shadow-lg"
      }
    }.freeze

    renders_one :header
    renders_one :footer
    renders_one :image, ->(src:, alt: "", **options) do
      tag.div(class: "sketch-card-image -mx-4 -mt-4 mb-4 overflow-hidden rounded-t-sketch-lg") do
        tag.img(src: src, alt: alt, class: "w-full h-48 object-cover", **options)
      end
    end

    def initialize(variant: :default, padding: :md, hoverable: false, clickable: false, href: nil, **options)
      @variant = variant
      @padding = padding
      @hoverable = hoverable
      @clickable = clickable
      @href = href
      super(**options)
    end

    def card_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:default])
      padding_class = case @padding
      when :none then ""
      when :sm then "p-3"
      when :md then "p-4"
      when :lg then "p-6"
      else "p-4"
      end

      [
        base_classes,
        variant_config[:bg],
        variant_config[:shadow],
        "border-2",
        "rounded-sketch-lg",
        padding_class,
        @hoverable ? "hover:shadow-sketch-lg hover:-translate-y-1 cursor-pointer" : "",
        @clickable ? "cursor-pointer" : ""
      ].compact.join(" ")
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

    def header?
      header.present?
    end

    def footer?
      footer.present?
    end

    def image?
      image.present?
    end
  end
end
