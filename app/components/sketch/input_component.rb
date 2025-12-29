# frozen_string_literal: true

module Sketch
  # Sketch 스타일 입력 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 폼 입력 필드
  #
  # 주요 기능:
  # - 다양한 입력 타입 지원 (text, email, password, textarea, select 등)
  # - 입력 스타일 변형 (default, filled, underline)
  # - 라벨, 도움말, 에러 메시지 표시
  # - 필수 입력 표시 및 ARIA 접근성 지원
  # - RoughJS 기반 스케치 테두리
  #
  # @param name [String] 입력 필드 name 속성
  # @param type [Symbol] 입력 타입 (:text, :email, :password, :textarea, :select 등)
  # @param variant [Symbol] 입력 스타일 (:default, :filled, :underline)
  # @param label [String] 라벨 텍스트
  # @param placeholder [String] 플레이스홀더 텍스트
  # @param helper [String] 도움말 텍스트
  # @param error [String] 에러 메시지
  # @param required [Boolean] 필수 입력 여부
  #
  # @example 기본 텍스트 입력
  #   render Sketch::InputComponent.new(name: "email", type: :email, placeholder: "이메일 입력")
  #
  # @example 라벨과 도움말 포함
  #   render Sketch::InputComponent.new(name: "username", label: "사용자명", helper: "고유한 이름을 선택하세요", required: true)
  class InputComponent < BaseComponent
    TYPES = %i[text email password tel url number date textarea select].freeze

    VARIANTS = {
      default: {
        bg: "bg-sketch-paper",
        border: "border-sketch-ink",
        focus: "focus:ring-sketch-ink"
      },
      filled: {
        bg: "bg-sketch-cream",
        border: "border-transparent",
        focus: "focus:ring-sketch-ink focus:border-sketch-ink"
      },
      underline: {
        bg: "bg-transparent",
        border: "border-b-2 border-t-0 border-l-0 border-r-0 rounded-none border-sketch-gray",
        focus: "focus:ring-0 focus:border-sketch-ink"
      }
    }.freeze

    def initialize(
      name:,
      type: :text,
      variant: :default,
      label: nil,
      placeholder: nil,
      value: nil,
      helper: nil,
      error: nil,
      required: false,
      rows: 3,
      options: [],
      **attrs
    )
      @name = name
      @type = type.to_sym
      @variant = variant
      @label = label
      @placeholder = placeholder
      @value = value
      @helper = helper
      @error = error
      @required = required
      @rows = rows
      @select_options = options
      @attrs = attrs
      super(**attrs.slice(:roughness, :size, :disabled, :loading))
    end

    def input_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:default])

      [
        base_classes,
        "w-full",
        size_config[:padding],
        size_config[:text],
        variant_config[:bg],
        "border-2",
        variant_config[:focus],
        "rounded-sketch-md",
        "font-sketch",
        "placeholder:text-sketch-gray placeholder:font-sketch",
        "focus:outline-none focus:ring-2 focus:ring-offset-1",
        @error ? "border-sketch-error" : "",
        disabled? ? "bg-sketch-cream/50" : ""
      ].compact.join(" ")
    end

    def input_data
      stimulus_data("input", {
        action: "focus->sketch-input#onFocus blur->sketch-input#onBlur"
      })
    end

    def wrapper_classes
      "sketch-input-wrapper relative"
    end

    def label_classes
      "block mb-1.5 font-sketch text-sm font-medium text-sketch-ink"
    end

    def helper_classes
      "mt-1.5 text-xs font-sketch text-sketch-gray"
    end

    def error_classes
      "mt-1.5 text-xs font-sketch text-sketch-error"
    end

    def input_id
      @attrs[:id] || "input_#{@name}"
    end

    def input_name
      @name
    end

    def input_type
      return nil if textarea? || select?
      @type.to_s
    end

    def textarea?
      @type == :textarea
    end

    def select?
      @type == :select
    end

    def has_label?
      @label.present?
    end

    def has_helper?
      @helper.present? && @error.blank?
    end

    def has_error?
      @error.present?
    end

    def required?
      @required
    end

    def placeholder_text
      @placeholder
    end

    def input_value
      @value
    end

    def textarea_rows
      @rows
    end

    def select_options
      @select_options
    end

    def label_text
      text = @label
      text += " *" if required?
      text
    end

    def helper_text
      @helper
    end

    def error_text
      @error
    end

    def aria_describedby
      return "#{input_id}_error" if has_error?
      return "#{input_id}_helper" if has_helper?
      nil
    end
  end
end
