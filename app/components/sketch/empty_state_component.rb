# frozen_string_literal: true

module Sketch
  # Sketch 스타일 빈 상태 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 빈 데이터 상태 표시
  #
  # 주요 기능:
  # - 아이콘, 제목, 설명 텍스트 표시
  # - 액션 버튼 링크 지원
  # - 다양한 크기 (sm, md, lg)
  # - 커스텀 액션 슬롯 지원
  #
  # @param title [String] 제목 텍스트 (필수)
  # @param description [String] 설명 텍스트
  # @param icon [String] 아이콘 이름
  # @param action_text [String] 액션 버튼 텍스트
  # @param action_href [String] 액션 버튼 링크 URL
  # @param size [Symbol] 크기 (:sm, :md, :lg)
  #
  # @example 기본 빈 상태
  #   render Sketch::EmptyStateComponent.new(icon: "image", title: "아직 사진이 없어요", description: "추억을 업로드해보세요")
  #
  # @example 액션 버튼 포함
  #   render Sketch::EmptyStateComponent.new(icon: "image", title: "아직 사진이 없어요", action_text: "사진 업로드", action_href: "/photos/new")
  class EmptyStateComponent < BaseComponent
    renders_one :action

    SIZES = {
      sm: { padding: "py-8", icon: "w-12 h-12", title: "text-lg", desc: "text-sm" },
      md: { padding: "py-12", icon: "w-16 h-16", title: "text-xl", desc: "text-base" },
      lg: { padding: "py-16", icon: "w-20 h-20", title: "text-2xl", desc: "text-lg" }
    }.freeze

    def initialize(
      title:,
      description: nil,
      icon: nil,
      action_text: nil,
      action_href: nil,
      size: :md,
      **options
    )
      @title = title
      @description = description
      @icon = icon
      @action_text = action_text
      @action_href = action_href
      @empty_size = size
      @custom_class = options.delete(:class)
      super(**options)
    end

    def container_classes
      size_config = SIZES.fetch(@empty_size, SIZES[:md])

      [
        "sketch-empty-state",
        "flex flex-col items-center justify-center",
        "text-center px-4",
        size_config[:padding],
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def has_icon?
      @icon.present?
    end

    def icon_name
      @icon
    end

    def icon_classes
      size_config = SIZES.fetch(@empty_size, SIZES[:md])
      "#{size_config[:icon]} text-sketch-gray/50"
    end

    def title_text
      @title
    end

    def title_classes
      size_config = SIZES.fetch(@empty_size, SIZES[:md])
      "font-sketch font-medium text-sketch-ink #{size_config[:title]}"
    end

    def has_description?
      @description.present?
    end

    def description_text
      @description
    end

    def description_classes
      size_config = SIZES.fetch(@empty_size, SIZES[:md])
      "font-hand text-sketch-gray #{size_config[:desc]}"
    end

    def has_action?
      @action_text.present? && @action_href.present?
    end

    def action_text
      @action_text
    end

    def action_href
      @action_href
    end
  end
end
