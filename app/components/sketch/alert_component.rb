# frozen_string_literal: true

module Sketch
  # Sketch 스타일 알림 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 알림/경고 메시지
  #
  # 주요 기능:
  # - 다양한 알림 타입 (info, success, warning, error)
  # - 제목 및 메시지 표시
  # - 닫기 버튼 (dismissible)
  # - 타입별 아이콘 및 색상 자동 적용
  # - ARIA role 자동 설정 (alert/status)
  #
  # @param message [String] 알림 메시지
  # @param variant [Symbol] 알림 타입 (:info, :success, :warning, :error)
  # @param title [String] 알림 제목 (선택)
  # @param dismissible [Boolean] 닫기 버튼 표시 여부
  #
  # @example 기본 알림
  #   render Sketch::AlertComponent.new(message: "저장되었습니다", variant: :success)
  #
  # @example 제목과 닫기 버튼 포함
  #   render Sketch::AlertComponent.new(title: "주의", message: "입력값을 확인하세요", variant: :warning, dismissible: true)
  class AlertComponent < BaseComponent
    VARIANTS = {
      info: {
        bg: "bg-blue-50",
        border: "border-blue-200",
        text: "text-blue-800",
        icon: "info",
        icon_color: "text-blue-500"
      },
      success: {
        bg: "bg-emerald-50",
        border: "border-emerald-200",
        text: "text-emerald-800",
        icon: "check-circle",
        icon_color: "text-emerald-500"
      },
      warning: {
        bg: "bg-amber-50",
        border: "border-amber-200",
        text: "text-amber-800",
        icon: "triangle-alert",
        icon_color: "text-amber-500"
      },
      error: {
        bg: "bg-red-50",
        border: "border-red-200",
        text: "text-red-800",
        icon: "circle-x",
        icon_color: "text-red-500"
      }
    }.freeze

    def initialize(message: nil, variant: :info, title: nil, dismissible: false, **options)
      @message = message
      @variant = variant
      @title = title
      @dismissible = dismissible
      @custom_class = options.delete(:class)
      super(**options)
    end

    def alert_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:info])

      [
        "sketch-alert",
        "flex items-start gap-3",
        "rounded-xl",
        "border p-4",
        variant_config[:bg],
        variant_config[:border],
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def text_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:info])
      "font-hand text-sm #{variant_config[:text]}"
    end

    def title_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:info])
      "font-semibold #{variant_config[:text]}"
    end

    def icon_name
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:info])
      variant_config[:icon]
    end

    def icon_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:info])
      "w-5 h-5 #{variant_config[:icon_color]}"
    end

    def close_button_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:info])
      "p-1 rounded-lg hover:bg-black/5 transition-colors #{variant_config[:text]}"
    end

    def has_title?
      @title.present?
    end

    def title_text
      @title
    end

    def message_text
      @message
    end

    def dismissible?
      @dismissible
    end

    def aria_role
      %i[error warning].include?(@variant) ? "alert" : "status"
    end

    def render?
      @message.present? || content.present?
    end
  end
end
