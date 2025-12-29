# frozen_string_literal: true

module Sketch
  # Sketch 스타일 리스트 아이템 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 리스트 항목
  #
  # 주요 기능:
  # - 제목 및 설명 텍스트 표시
  # - 아이콘 또는 커스텀 leading 슬롯
  # - 뱃지 또는 커스텀 trailing 슬롯
  # - 링크 또는 일반 div로 렌더링
  # - 화살표 표시 (show_chevron)
  # - 다양한 스타일 변형 (default, setting, member)
  #
  # @param title [String] 제목 텍스트 (필수)
  # @param description [String] 설명 텍스트
  # @param href [String] 링크 URL
  # @param icon [String] 왼쪽 아이콘 이름
  # @param show_chevron [Boolean] 오른쪽 화살표 표시 여부
  # @param variant [Symbol] 스타일 변형 (:default, :setting, :member)
  #
  # @example 기본 리스트 아이템
  #   render Sketch::ListItemComponent.new(title: "설정", icon: "settings")
  #
  # @example 링크 및 화살표 포함
  #   render Sketch::ListItemComponent.new(title: "프로필", description: "프로필 편집", href: "/settings/profile", show_chevron: true)
  class ListItemComponent < BaseComponent
    renders_one :leading
    renders_one :trailing

    VARIANTS = {
      default: "",
      setting: "hover:bg-sketch-cream transition-colors",
      member: "hover:bg-sketch-cream/50"
    }.freeze

    def initialize(title:, description: nil, href: nil, icon: nil, show_chevron: false, variant: :default, **options)
      @title = title
      @description = description
      @href = href
      @icon = icon
      @show_chevron = show_chevron
      @variant = variant
      @custom_class = options.delete(:class)
      super(**options)
    end

    def list_item_classes
      variant_classes = VARIANTS.fetch(@variant, VARIANTS[:default])

      [
        "sketch-list-item",
        "flex items-center gap-3",
        "py-3 px-4",
        variant_classes,
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def list_item_tag
      @href.present? ? :a : :div
    end

    def list_item_options
      opts = { class: list_item_classes }
      opts[:href] = @href if @href.present?
      opts
    end

    def has_icon?
      @icon.present?
    end

    def icon_name
      @icon
    end

    def title_text
      @title
    end

    def has_description?
      @description.present?
    end

    def description_text
      @description
    end

    def show_chevron?
      @show_chevron
    end

    def has_leading?
      leading? || has_icon?
    end
  end
end
