# frozen_string_literal: true

module Sketch
  # Sketch 스타일 아바타 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 사용자 아바타
  #
  # 주요 기능:
  # - 이미지 또는 이니셜 표시
  # - 다양한 크기 지원 (xs, sm, md, lg, xl)
  # - 온라인 상태 표시기 (online, offline, away, busy)
  # - 스케치 스타일 테두리
  #
  # @param src [String] 아바타 이미지 URL
  # @param alt [String] 이미지 대체 텍스트
  # @param size [Symbol] 아바타 크기 (:xs, :sm, :md, :lg, :xl)
  # @param initials [String] 이니셜 (이미지 없을 때 표시)
  # @param border [Boolean] 테두리 표시 여부
  # @param status [Symbol] 상태 표시 (:online, :offline, :away, :busy)
  #
  # @example 이미지 아바타
  #   render Sketch::AvatarComponent.new(src: user.avatar_url, alt: user.name)
  #
  # @example 이니셜 아바타 (상태 표시 포함)
  #   render Sketch::AvatarComponent.new(initials: "MJ", size: :lg, status: :online)
  class AvatarComponent < BaseComponent
    SIZES = {
      xs: { container: "w-6 h-6", text: "text-xs", icon: "w-3 h-3", status: "w-2 h-2" },
      sm: { container: "w-8 h-8", text: "text-sm", icon: "w-4 h-4", status: "w-2 h-2" },
      md: { container: "w-10 h-10", text: "text-base", icon: "w-5 h-5", status: "w-3 h-3" },
      lg: { container: "w-12 h-12", text: "text-lg", icon: "w-6 h-6", status: "w-3 h-3" },
      xl: { container: "w-16 h-16", text: "text-xl", icon: "w-8 h-8", status: "w-4 h-4" }
    }.freeze

    STATUS_COLORS = {
      online: "bg-emerald-500",
      offline: "bg-gray-400",
      away: "bg-amber-500",
      busy: "bg-red-500"
    }.freeze

    def initialize(src: nil, alt: "", size: :md, initials: nil, border: true, status: nil, **options)
      @src = src
      @alt = alt
      @avatar_size = size
      @initials = initials
      @border = border
      @status = status
      @custom_class = options.delete(:class)
      super(**options)
    end

    def avatar_classes
      size_config = SIZES.fetch(@avatar_size, SIZES[:md])

      [
        "sketch-avatar",
        "relative inline-flex items-center justify-center",
        "rounded-full",
        "bg-sketch-cream",
        "font-sketch font-medium text-sketch-ink",
        size_config[:container],
        size_config[:text],
        @border ? "border-2 border-sketch-ink" : "",
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def has_image?
      @src.present?
    end

    def has_initials?
      @initials.present?
    end

    def displayed_initials
      @initials.to_s.upcase[0..1]
    end

    def image_src
      @src
    end

    def image_alt
      @alt
    end

    def has_status?
      @status.present?
    end

    def status_classes
      size_config = SIZES.fetch(@avatar_size, SIZES[:md])
      status_color = STATUS_COLORS.fetch(@status, STATUS_COLORS[:offline])

      [
        "absolute bottom-0 right-0",
        "rounded-full",
        "border-2 border-white",
        size_config[:status],
        status_color
      ].join(" ")
    end

    def icon_classes
      size_config = SIZES.fetch(@avatar_size, SIZES[:md])
      "#{size_config[:icon]} text-sketch-gray"
    end
  end
end
