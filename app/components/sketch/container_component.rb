# frozen_string_literal: true

module Sketch
  # Sketch 스타일 컨테이너 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 콘텐츠 래퍼
  #
  # 주요 기능:
  # - 다양한 배경 스타일 (default, paper, cream, glass, card)
  # - 다양한 패딩 크기 (none, sm, md, lg, xl)
  # - RoughJS 기반 스케치 테두리 (선택적)
  # - 커스텀 HTML 태그 지원
  #
  # @param tag [Symbol] HTML 태그 (:div, :section, :article 등)
  # @param variant [Symbol] 배경 스타일 (:default, :paper, :cream, :glass, :card)
  # @param border [Boolean] 스케치 테두리 표시 여부
  # @param padding [Symbol] 내부 여백 (:none, :sm, :md, :lg, :xl)
  #
  # @example 기본 컨테이너
  #   render Sketch::ContainerComponent.new { "콘텐츠" }
  #
  # @example 카드 스타일 섹션
  #   render Sketch::ContainerComponent.new(tag: :section, variant: :card) { "카드 콘텐츠" }
  class ContainerComponent < BaseComponent
    VARIANTS = {
      default: "bg-white",
      paper: "bg-sketch-paper",
      cream: "bg-sketch-cream",
      glass: "bg-white/70 backdrop-blur-md",
      card: "bg-white rounded-xl border border-sketch-gray/20 shadow-sm"
    }.freeze

    PADDING = {
      none: "p-0",
      sm: "p-2",
      md: "p-4",
      lg: "p-6",
      xl: "p-8"
    }.freeze

    def initialize(tag: :div, variant: :default, border: true, padding: :md, **options)
      @tag = tag
      @variant = variant
      @border = border
      @padding = padding
      @custom_class = options.delete(:class)
      super(**options)
    end

    def container_tag
      @tag
    end

    def container_classes
      variant_classes = VARIANTS.fetch(@variant, VARIANTS[:default])
      padding_classes = PADDING.fetch(@padding, PADDING[:md])

      [
        "sketch-container",
        "relative",
        variant_classes,
        padding_classes,
        @border ? "sketch-border-container" : "",
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def container_data
      return {} unless @border

      {
        controller: "sketch-border",
        "sketch-border-roughness-value": roughness_value
      }
    end
  end
end
